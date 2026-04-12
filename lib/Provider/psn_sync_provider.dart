import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:game_trophy_manager/Model/game_guide_model.dart';
import 'package:game_trophy_manager/Model/game_model.dart';
import 'package:game_trophy_manager/Model/merged_game_model.dart';
import 'package:game_trophy_manager/Model/psn_game_snapshot.dart';
import 'package:game_trophy_manager/Model/psn_profile_cache.dart';
import 'package:game_trophy_manager/Provider/internal_db_provider.dart';
import 'package:game_trophy_manager/Utilities/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PsnSyncProvider extends ChangeNotifier {
  static const String _npssoKey = 'psn_npsso';
  static const String _profileKey = 'psn_profile';
  static const String _lastSyncAtKey = 'psn_last_sync_at';
  static const String _lastSyncStatusKey = 'psn_last_sync_status';
  static const String _lastSyncErrorKey = 'psn_last_sync_error';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Dio _dio = Dio();

  PsnProfileCache? profile;
  DateTime? lastSyncAt;
  String syncStatus = 'idle';
  String syncError = '';
  bool isBusy = false;
  String busyTitle = '';
  String busyMessage = '';
  List<String> busyImageUrls = <String>[];
  DateTime? busyStartedAt;
  bool _initialized = false;
  Timer? _busyHintTimer;
  List<String> _busyHints = const <String>[];
  int _busyHintIndex = 0;
  bool _busyCatalogImagesRequested = false;

  bool get isConnected => profile != null;
  bool get hasCachedLibrary => true;
  static const bool _enablePsnSyncDebugLogs = true;

  String busyElapsedLabel() {
    if (!isBusy || busyStartedAt == null) return '';
    final diff = DateTime.now().difference(busyStartedAt!);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    final minutes = diff.inMinutes;
    final seconds = diff.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  Future<void> initialize(InternalDbProvider dbProvider) async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    final profileString = prefs.getString(_profileKey);
    if (profileString != null && profileString.isNotEmpty) {
      profile = PsnProfileCache.fromJson(jsonDecode(profileString));
    }
    final lastSyncString = prefs.getString(_lastSyncAtKey);
    if (lastSyncString != null && lastSyncString.isNotEmpty) {
      lastSyncAt = DateTime.tryParse(lastSyncString);
    }
    syncStatus = prefs.getString(_lastSyncStatusKey) ?? 'idle';
    syncError = prefs.getString(_lastSyncErrorKey) ?? '';

    await dbProvider.getAllPsnGamesFromDb();
    notifyListeners();
  }

  Future<bool> connectWithNpsso(
    String npsso,
    InternalDbProvider dbProvider,
  ) async {
    if (npsso.trim().isEmpty) {
      syncError = 'Could not detect a valid PSN session token yet.';
      notifyListeners();
      return false;
    }

    syncError = '';
    _beginBusy(
      title: 'Connecting to PSN',
      hints: const <String>[
        'Validating your PlayStation session...',
        'Preparing your first sync...',
      ],
      initialMessage: 'Validating your PlayStation session...',
    );
    _setBusyImageUrls(
      _collectCachedPreviewImages(dbProvider),
      notify: false,
    );
    _primeBusyCatalogImages();
    notifyListeners();

    try {
      final response = await _dio.post(
        baseUrl + psnValidateUrl,
        data: {'npsso': npsso.trim()},
      );
      profile = PsnProfileCache.fromJson(
        (response.data['profile'] as Map).cast<String, dynamic>(),
      );
      syncStatus = response.data['sync_meta']?['status'] ?? 'validated';
      await _secureStorage.write(key: _npssoKey, value: npsso.trim());
      await _persistState();
      notifyListeners();
      _setBusyMessage('Session verified. Starting initial sync...');
      return await syncNow(dbProvider, force: true, manageBusy: false);
    } on DioException catch (error) {
      syncStatus = 'error';
      syncError = _errorFromResponse(error);
      await _persistState();
      notifyListeners();
      return false;
    } finally {
      _endBusy();
    }
  }

  Future<bool> syncNow(
    InternalDbProvider dbProvider, {
    bool force = false,
    bool manageBusy = true,
  }) async {
    final npsso = await _secureStorage.read(key: _npssoKey);
    if (npsso == null || npsso.isEmpty) {
      syncStatus = 'error';
      syncError = 'Reconnect your PSN account to refresh.';
      notifyListeners();
      return false;
    }

    if (manageBusy) {
      _beginBusy(
        title: 'Syncing your PSN data',
        hints: const <String>[
          'Fetching your PSN library...',
          'Matching titles with your local catalog...',
          'Importing completed trophies...',
          'Saving synced data on this device...',
        ],
        initialMessage: 'Fetching your PSN library...',
      );
      _setBusyImageUrls(
        _collectCachedPreviewImages(dbProvider),
        notify: false,
      );
      _primeBusyCatalogImages();
    } else {
      _setBusyMessage('Fetching your PSN library...');
    }

    syncError = '';
    syncStatus = 'syncing';
    notifyListeners();

    try {
      final response = await _dio.post(
        baseUrl + psnSyncUrl,
        data: {'npsso': npsso},
      );
      final profileJson =
          (response.data['profile'] as Map).cast<String, dynamic>();
      profile = PsnProfileCache.fromJson(profileJson);

      _setBusyMessage('Matching titles with your local catalog...');
      final List<dynamic> rawLibrary = response.data['library'] ?? <dynamic>[];
      final responsePreviewImages = <String>[];
      for (final item in rawLibrary) {
        final data = (item as Map).cast<String, dynamic>();
        responsePreviewImages.add((data['image_url'] ?? '').toString());
        final catalogMatch = data['catalog_match'];
        if (catalogMatch is Map) {
          responsePreviewImages
              .add((catalogMatch['game_image_link'] ?? '').toString());
        }
      }
      _setBusyImageUrls(
        <String>[
          ...responsePreviewImages,
          ...busyImageUrls,
        ],
      );

      final List<GameModel> matchedGames = <GameModel>[];
      final List<PsnGameSnapshot> psnGames = <PsnGameSnapshot>[];
      final List<GuideModel> completedTrophies = <GuideModel>[];
      final Map<String, String> canonicalNameByTitleId = <String, String>{};
      for (final item in rawLibrary) {
        final data = (item as Map).cast<String, dynamic>();
        final titleId =
            (data['title_id'] ?? '').toString().trim().toUpperCase();
        final catalogMatch = data['catalog_match'];
        if (catalogMatch is Map) {
          final catalogData = catalogMatch.cast<String, dynamic>();
          final catalogGameName = (catalogData['game_name'] ?? '').toString();
          final catalogPlatform = catalogData['platform']?.toString() ?? 'ps4';
          final psnPlatform = data['platform']?.toString() ?? catalogPlatform;
          if (titleId.isNotEmpty && catalogGameName.isNotEmpty) {
            canonicalNameByTitleId[titleId] = catalogGameName;
          }
          matchedGames.add(
            GameModel(
              gameName: catalogGameName,
              gameImageUrl: catalogData['game_image_link'] ?? '',
              gold: catalogData['gold'] ?? '',
              silver: catalogData['silver'] ?? '',
              bronze: catalogData['bronze'] ?? '',
              platinum: catalogData['platinum'] ?? '',
              guideEndpoint:
                  catalogPlatform == 'ps5' ? ps5GuideUrl : ps4GuideUrl,
              platform: psnPlatform,
            ),
          );

          final rawCompletedTrophies =
              data['catalog_completed_trophies'] as List<dynamic>? ??
                  <dynamic>[];
          for (final trophy in rawCompletedTrophies) {
            final trophyData = (trophy as Map).cast<String, dynamic>();
            final guide = GuideModel.fromJson(trophyData);
            guide.gameName = catalogData['game_name'] ?? data['name'] ?? '';
            guide.gameImgUrl =
                catalogData['game_image_link'] ?? data['image_url'] ?? '';
            completedTrophies.add(guide);
          }
        }
        final snapshotPayload = Map<String, dynamic>.from(data);
        if (titleId.isNotEmpty && canonicalNameByTitleId.containsKey(titleId)) {
          snapshotPayload['name'] = canonicalNameByTitleId[titleId];
        }
        psnGames.add(PsnGameSnapshot.fromJson(snapshotPayload));
      }
      final dedupedPsnGames = _dedupePsnGames(psnGames);
      _logPsnSyncDiagnostics(
        rawLibrary: rawLibrary,
        parsedSnapshots: psnGames,
        dedupedSnapshots: dedupedPsnGames,
        matchedGames: matchedGames,
      );

      _setBusyMessage('Saving synced data on this device...');
      await dbProvider.upsertGamesFromSync(matchedGames);
      await dbProvider.replacePsnGamesSnapshot(dedupedPsnGames);
      await dbProvider.replacePsnCompletedTrophies(completedTrophies);

      final syncedAt = response.data['sync_meta']?['synced_at']?.toString();
      lastSyncAt =
          syncedAt != null ? DateTime.tryParse(syncedAt) : DateTime.now();
      syncStatus = response.data['sync_meta']?['status'] ?? 'success';
      syncError = response.data['sync_meta']?['error'] ?? '';
      await _persistState();
      _setBusyMessage('Sync complete. Finalizing...');
      notifyListeners();
      return true;
    } on DioException catch (error) {
      syncStatus = 'error';
      syncError = _errorFromResponse(error);
      _setBusyMessage('Sync failed. Please try again.');
      await _persistState();
      notifyListeners();
      return false;
    } finally {
      if (manageBusy) {
        _endBusy();
      }
    }
  }

  Future<void> refreshIfStale(
    InternalDbProvider dbProvider, {
    Duration maxAge = const Duration(hours: 24),
    bool force = false,
  }) async {
    if (!isConnected || isBusy) return;
    final shouldRefresh = force ||
        lastSyncAt == null ||
        DateTime.now().difference(lastSyncAt!) >= maxAge;
    if (!shouldRefresh) return;
    await syncNow(dbProvider, force: force);
  }

  Future<void> disconnect(InternalDbProvider dbProvider) async {
    await _secureStorage.delete(key: _npssoKey);
    profile = null;
    lastSyncAt = null;
    syncStatus = 'idle';
    syncError = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    await prefs.remove(_lastSyncAtKey);
    await prefs.remove(_lastSyncStatusKey);
    await prefs.remove(_lastSyncErrorKey);
    await dbProvider.clearPsnGamesSnapshot();
    await dbProvider.clearPsnCompletedTrophies();
    notifyListeners();
  }

  @override
  void dispose() {
    _busyHintTimer?.cancel();
    super.dispose();
  }

  List<MergedGameModel> mergeGames(
    List<GameModel> localGames,
    List<PsnGameSnapshot> psnGames,
    List<GuideModel> completed,
    List<GuideModel> starred,
  ) {
    final Map<String, GameModel> localByKey = <String, GameModel>{};
    for (final game in localGames) {
      final key = _gameKey(game.gameName);
      final current = localByKey[key];
      localByKey[key] = _preferLocalGame(current, game);
    }

    final Map<String, PsnGameSnapshot> psnByKey = <String, PsnGameSnapshot>{};
    for (final game in psnGames) {
      final key = _gameKey(game.name);
      final current = psnByKey[key];
      psnByKey[key] = _preferPsnGame(current, game);
    }

    final Set<String> allKeys = {...localByKey.keys, ...psnByKey.keys};
    final List<MergedGameModel> merged = allKeys.map((key) {
      final localGame = localByKey[key];
      final psnGame = psnByKey[key];
      final fallbackName = localGame?.gameName ?? psnGame?.name ?? '';
      return MergedGameModel(
        localGame: localGame,
        psnGame: psnGame,
        localCompletedCount: _countByGameName(completed, fallbackName),
        localStarredCount: _countByGameName(starred, fallbackName),
      );
    }).toList();

    merged.sort((a, b) {
      final aPsn = a.psnGame?.lastPlayedAt ?? '';
      final bPsn = b.psnGame?.lastPlayedAt ?? '';
      if (aPsn != bPsn) return bPsn.compareTo(aPsn);
      return a.gameName.toLowerCase().compareTo(b.gameName.toLowerCase());
    });
    return merged;
  }

  String lastSyncLabel() {
    if (lastSyncAt == null) return 'Never synced';
    final diff = DateTime.now().difference(lastSyncAt!);
    if (diff.inMinutes < 1) return 'Synced just now';
    if (diff.inHours < 1) return 'Synced ${diff.inMinutes}m ago';
    if (diff.inDays < 1) return 'Synced ${diff.inHours}h ago';
    return 'Synced ${diff.inDays}d ago';
  }

  Future<void> _persistState() async {
    final prefs = await SharedPreferences.getInstance();
    if (profile != null) {
      await prefs.setString(_profileKey, jsonEncode(profile!.toJson()));
    } else {
      await prefs.remove(_profileKey);
    }
    if (lastSyncAt != null) {
      await prefs.setString(_lastSyncAtKey, lastSyncAt!.toIso8601String());
    } else {
      await prefs.remove(_lastSyncAtKey);
    }
    await prefs.setString(_lastSyncStatusKey, syncStatus);
    await prefs.setString(_lastSyncErrorKey, syncError);
  }

  String _gameKey(String name) {
    final normalizedName = _identityName(name);
    return normalizedName;
  }

  int _countByGameName(List<GuideModel> trophies, String gameName) {
    final target = _identityName(gameName);
    return trophies.where((guide) {
      final current = _identityName(guide.gameName);
      return current == target;
    }).length;
  }

  String _identityName(String name) {
    var normalized = name.toLowerCase();
    normalized = normalized
        .replaceAll(RegExp(r'\(.*?playstation\s*5.*?\)'), ' ')
        .replaceAll(RegExp(r'\(.*?playstation\s*4.*?\)'), ' ')
        .replaceAll(RegExp(r'\(.*?ps5.*?\)'), ' ')
        .replaceAll(RegExp(r'\(.*?ps4.*?\)'), ' ')
        .replaceAll('playstation 5', ' ')
        .replaceAll('playstation5', ' ')
        .replaceAll('playstation 4', ' ')
        .replaceAll('playstation4', ' ')
        .replaceAll(' for ps5', ' ')
        .replaceAll(' for ps4', ' ');
    normalized = normalized
        .replaceAll('playstation', '')
        .replaceAll('ps4', '')
        .replaceAll('ps5', '')
        .replaceAll('edition', '')
        .replaceAll('digital', '')
        .replaceAll('bundle', '')
        .replaceAll('crossgen', '')
        .replaceAll('cross-gen', '')
        .replaceAll('cross gen', '');

    const Map<String, String> romanToNumber = <String, String>{
      ' viii ': ' 8 ',
      ' vii ': ' 7 ',
      ' vi ': ' 6 ',
      ' v ': ' 5 ',
      ' iv ': ' 4 ',
      ' iii ': ' 3 ',
      ' ii ': ' 2 ',
      ' i ': ' 1 ',
    };

    var padded = ' $normalized ';
    romanToNumber.forEach((roman, number) {
      padded = padded.replaceAll(roman, number);
    });

    return padded.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  String _looseIdentityName(String name) {
    var normalized = name.toLowerCase();
    normalized = normalized
        .replaceAll(RegExp(r'\(.*?\)'), ' ')
        .replaceAll('standard', ' ')
        .replaceAll('ultimate', ' ')
        .replaceAll('definitive', ' ')
        .replaceAll('complete', ' ')
        .replaceAll('edition', ' ')
        .replaceAll('remastered', ' ')
        .replaceAll('collection', ' ')
        .replaceAll('bundle', ' ')
        .replaceAll('digital', ' ')
        .replaceAll('legacy', ' ');
    return normalized.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  int _earnedFromPayload(Map<String, dynamic> data) {
    final earned =
        (data['earned_counts'] as Map?)?.cast<String, dynamic>() ?? {};
    return (int.tryParse('${earned['bronze'] ?? 0}') ?? 0) +
        (int.tryParse('${earned['silver'] ?? 0}') ?? 0) +
        (int.tryParse('${earned['gold'] ?? 0}') ?? 0) +
        (int.tryParse('${earned['platinum'] ?? 0}') ?? 0);
  }

  int _completionFromPayload(Map<String, dynamic> data) {
    return int.tryParse('${data['completion_percent'] ?? 0}') ?? 0;
  }

  String _safeString(dynamic value) {
    return (value ?? '').toString();
  }

  void _logPsnSyncDiagnostics({
    required List<dynamic> rawLibrary,
    required List<PsnGameSnapshot> parsedSnapshots,
    required List<PsnGameSnapshot> dedupedSnapshots,
    required List<GameModel> matchedGames,
  }) {
    if (!_enablePsnSyncDebugLogs) return;

    debugPrint(
      '[PSN_SYNC_DEBUG] start raw=${rawLibrary.length} parsed=${parsedSnapshots.length} deduped=${dedupedSnapshots.length} matched=${matchedGames.length}',
    );

    final byTitleId = <String, List<Map<String, dynamic>>>{};
    final byIdentity = <String, List<Map<String, dynamic>>>{};
    final byLoose = <String, List<Map<String, dynamic>>>{};

    for (final item in rawLibrary) {
      final data = (item as Map).cast<String, dynamic>();
      final titleId = _safeString(data['title_id']).trim().toUpperCase();
      final name = _safeString(data['name']);
      final platform = _safeString(data['platform']);
      final identityKey = _identityName(name);
      final looseKey = _looseIdentityName(name);
      final row = <String, dynamic>{
        'title_id': titleId,
        'name': name,
        'platform': platform,
        'completion': _completionFromPayload(data),
        'earned_total': _earnedFromPayload(data),
        'matched_catalog': data['catalog_match'] is Map,
      };

      if (titleId.isNotEmpty) {
        byTitleId.putIfAbsent(titleId, () => <Map<String, dynamic>>[]).add(row);
      }
      byIdentity
          .putIfAbsent(identityKey, () => <Map<String, dynamic>>[])
          .add(row);
      byLoose.putIfAbsent(looseKey, () => <Map<String, dynamic>>[]).add(row);
    }

    final duplicateIds =
        byTitleId.entries.where((entry) => entry.value.length > 1);
    for (final entry in duplicateIds) {
      debugPrint(
          '[PSN_SYNC_DEBUG] duplicate title_id=${entry.key} rows=${entry.value.length}');
      for (final row in entry.value) {
        debugPrint(
          '[PSN_SYNC_DEBUG]   row id=${row['title_id']} platform=${row['platform']} completion=${row['completion']} earned=${row['earned_total']} matched=${row['matched_catalog']} name="${row['name']}"',
        );
      }
    }

    final duplicateIdentity = byIdentity.entries
        .where((entry) => entry.key.isNotEmpty && entry.value.length > 1);
    for (final entry in duplicateIdentity) {
      debugPrint(
        '[PSN_SYNC_DEBUG] duplicate identity_key=${entry.key} rows=${entry.value.length}',
      );
      for (final row in entry.value) {
        debugPrint(
          '[PSN_SYNC_DEBUG]   row id=${row['title_id']} platform=${row['platform']} completion=${row['completion']} earned=${row['earned_total']} matched=${row['matched_catalog']} name="${row['name']}"',
        );
      }
    }

    final looseCandidates = byLoose.entries.where(
      (entry) =>
          entry.key.isNotEmpty &&
          entry.value.length > 1 &&
          entry.value.map((row) => row['name']).toSet().length > 1,
    );
    for (final entry in looseCandidates) {
      debugPrint(
        '[PSN_SYNC_DEBUG] loose-match candidate key=${entry.key} rows=${entry.value.length}',
      );
      for (final row in entry.value) {
        debugPrint(
          '[PSN_SYNC_DEBUG]   row id=${row['title_id']} platform=${row['platform']} completion=${row['completion']} earned=${row['earned_total']} matched=${row['matched_catalog']} name="${row['name']}"',
        );
      }
    }

    debugPrint('[PSN_SYNC_DEBUG] end');
  }

  int _localSignal(GameModel game) {
    final gold = int.tryParse(game.gold) ?? 0;
    final silver = int.tryParse(game.silver) ?? 0;
    final bronze = int.tryParse(game.bronze) ?? 0;
    final platinum = int.tryParse(game.platinum) ?? 0;
    return (gold * 100) + (silver * 10) + bronze + (platinum * 1000);
  }

  GameModel _preferLocalGame(GameModel? current, GameModel incoming) {
    if (current == null) return incoming;
    final currentSignal = _localSignal(current);
    final incomingSignal = _localSignal(incoming);
    if (incomingSignal > currentSignal) return incoming;
    if (incomingSignal < currentSignal) return current;
    final incomingHasPs5 = incoming.platform.toLowerCase().contains('5');
    final currentHasPs5 = current.platform.toLowerCase().contains('5');
    if (incomingHasPs5 && !currentHasPs5) return incoming;
    return current;
  }

  int _psnSignal(PsnGameSnapshot game) {
    final earnedTotal = game.earnedBronze +
        game.earnedSilver +
        game.earnedGold +
        game.earnedPlatinum;
    final totalTotal = game.totalBronze +
        game.totalSilver +
        game.totalGold +
        game.totalPlatinum;
    return (game.completionPercent * 1000) + (earnedTotal * 10) + totalTotal;
  }

  PsnGameSnapshot _preferPsnGame(
    PsnGameSnapshot? current,
    PsnGameSnapshot incoming,
  ) {
    if (current == null) return incoming;
    final currentSignal = _psnSignal(current);
    final incomingSignal = _psnSignal(incoming);
    if (incomingSignal > currentSignal) return incoming;
    if (incomingSignal < currentSignal) return current;

    final incomingHasImage = incoming.imageUrl.trim().isNotEmpty;
    final currentHasImage = current.imageUrl.trim().isNotEmpty;
    if (incomingHasImage && !currentHasImage) return incoming;
    return current;
  }

  List<PsnGameSnapshot> _dedupePsnGames(List<PsnGameSnapshot> games) {
    final byKey = <String, PsnGameSnapshot>{};
    for (final game in games) {
      final titleId = game.titleId.trim().toUpperCase();
      final key =
          titleId.isNotEmpty ? 'id::$titleId' : 'name::${_gameKey(game.name)}';
      byKey[key] = _preferPsnGame(byKey[key], game);
    }
    return byKey.values.toList();
  }

  String _errorFromResponse(DioException error) {
    final data = error.response?.data;
    if (data is Map &&
        data['sync_meta'] is Map &&
        data['sync_meta']['error'] != null) {
      return data['sync_meta']['error'].toString();
    }
    return error.message ?? 'Unable to reach PSN sync right now.';
  }

  void _beginBusy({
    required String title,
    required List<String> hints,
    String? initialMessage,
  }) {
    _busyHintTimer?.cancel();
    _busyHints = hints.where((hint) => hint.trim().isNotEmpty).toList();
    _busyHintIndex = 0;
    _busyCatalogImagesRequested = false;
    isBusy = true;
    busyStartedAt = DateTime.now();
    busyTitle = title;
    busyMessage = initialMessage?.trim().isNotEmpty == true
        ? initialMessage!.trim()
        : (_busyHints.isNotEmpty ? _busyHints.first : '');
    notifyListeners();

    if (_busyHints.length <= 1) return;
    _busyHintTimer = Timer.periodic(Duration(seconds: 3), (_) {
      if (!isBusy || _busyHints.isEmpty) return;
      _busyHintIndex = (_busyHintIndex + 1) % _busyHints.length;
      busyMessage = _busyHints[_busyHintIndex];
      notifyListeners();
    });
  }

  void _setBusyMessage(String message) {
    if (!isBusy) return;
    final normalized = message.trim();
    if (normalized.isEmpty || normalized == busyMessage) return;
    busyMessage = normalized;
    notifyListeners();
  }

  void _endBusy() {
    _busyHintTimer?.cancel();
    _busyHintTimer = null;
    isBusy = false;
    busyTitle = '';
    busyMessage = '';
    busyImageUrls = <String>[];
    busyStartedAt = null;
    _busyHints = const <String>[];
    _busyHintIndex = 0;
    _busyCatalogImagesRequested = false;
    notifyListeners();
  }

  void _primeBusyCatalogImages() {
    if (_busyCatalogImagesRequested || !isBusy) return;
    _busyCatalogImagesRequested = true;
    _fetchShowcaseCatalogImageUrls().then((urls) {
      if (!isBusy || urls.isEmpty) return;
      _setBusyImageUrls(
        <String>[
          ...busyImageUrls,
          ...urls,
        ],
      );
    }).catchError((_) {});
  }

  List<String> _collectCachedPreviewImages(InternalDbProvider dbProvider) {
    final urls = <String>[];
    for (final game in dbProvider.myPsnGames) {
      urls.add(game.imageUrl);
    }
    for (final game in dbProvider.myGames) {
      urls.add(game.gameImageUrl);
    }
    for (final trophy in dbProvider.myCompletedTrophy) {
      urls.add(trophy.gameImgUrl);
    }
    return urls;
  }

  Future<List<String>> _fetchShowcaseCatalogImageUrls() async {
    final candidates = <Map<String, dynamic>>[];
    final franchiseQueries = <String, List<String>>{
      'gta': <String>['Grand Theft Auto'],
      'cod': <String>['Call of Duty'],
      'gow': <String>['God of War'],
      'spiderman': <String>['Spider-Man', 'Spider Man'],
      'witcher': <String>['Witcher'],
      'tlou': <String>['The Last of Us', 'Last of Us'],
    };
    final franchiseRows = <String, List<Map<String, dynamic>>>{};
    final random = Random();

    Future<void> fetchSearch({
      required String endpoint,
      required String query,
      required String franchiseKey,
    }) async {
      try {
        final response = await _dio.get(
          '$baseUrl$endpoint/',
          queryParameters: {
            'page': 1,
            'search': query,
          },
        );
        final data = response.data;
        if (data is! Map) return;
        final results = data['results'];
        if (results is! List) return;
        for (final row in results) {
          if (row is Map) {
            franchiseRows.putIfAbsent(
              franchiseKey,
              () => <Map<String, dynamic>>[],
            );
            franchiseRows[franchiseKey]!.add(row.cast<String, dynamic>());
          }
        }
      } catch (_) {}
    }

    Future<void> fetchEndpoint(String endpoint) async {
      try {
        final response = await _dio.get(
          '$baseUrl$endpoint/',
          queryParameters: {
            'page': 1,
            'search': '',
          },
        );
        final data = response.data;
        if (data is! Map) return;
        final results = data['results'];
        if (results is! List) return;
        for (final row in results) {
          if (row is Map) {
            candidates.add(row.cast<String, dynamic>());
          }
        }
      } catch (_) {}
    }

    for (final entry in franchiseQueries.entries) {
      final franchiseKey = entry.key;
      for (final query in entry.value) {
        await Future.wait([
          fetchSearch(
            endpoint: ps4GamesUrl,
            query: query,
            franchiseKey: franchiseKey,
          ),
          fetchSearch(
            endpoint: ps5GamesUrl,
            query: query,
            franchiseKey: franchiseKey,
          ),
        ]);
      }
    }

    await Future.wait([
      fetchEndpoint(ps4GamesUrl),
      fetchEndpoint(ps5GamesUrl),
    ]);

    final urls = <String>[];
    final seen = <String>{};

    // Take a balanced mix from showcase franchises first.
    for (final key in franchiseQueries.keys) {
      final rows = List<Map<String, dynamic>>.from(
        franchiseRows[key] ?? const <Map<String, dynamic>>[],
      );
      rows.shuffle(random);
      var addedForKey = 0;
      for (final row in rows) {
        final imageUrl = (row['game_image_link'] ?? '').toString().trim();
        if (imageUrl.isEmpty) continue;
        if (!seen.add(imageUrl)) continue;
        urls.add(imageUrl);
        addedForKey += 1;
        if (addedForKey >= 3) break;
        if (urls.length >= 18) break;
      }
      if (urls.length >= 18) break;
    }

    if (candidates.isEmpty) return urls;

    final randomRows = List<Map<String, dynamic>>.from(candidates);
    randomRows.shuffle(random);
    if (urls.length < 20) {
      for (final row in randomRows) {
        final imageUrl = (row['game_image_link'] ?? '').toString().trim();
        if (imageUrl.isEmpty) continue;
        if (!seen.add(imageUrl)) continue;
        urls.add(imageUrl);
        if (urls.length >= 20) break;
      }
    }
    return urls;
  }

  void _setBusyImageUrls(
    List<String> rawUrls, {
    bool notify = true,
  }) {
    final deduped = <String>[];
    final seen = <String>{};

    for (final raw in rawUrls) {
      var url = raw.trim();
      if (url.isEmpty) continue;
      if (url.startsWith('//')) {
        url = 'https:$url';
      }
      if (!(url.startsWith('https://') || url.startsWith('http://'))) {
        continue;
      }
      if (seen.add(url)) {
        deduped.add(url);
      }
      if (deduped.length >= 20) break;
    }

    final current = busyImageUrls;
    final isSame = current.length == deduped.length &&
        current
            .asMap()
            .entries
            .every((entry) => deduped[entry.key] == entry.value);
    if (isSame) return;

    busyImageUrls = deduped;
    if (notify) {
      notifyListeners();
    }
  }
}
