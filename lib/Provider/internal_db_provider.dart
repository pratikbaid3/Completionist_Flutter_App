import 'package:flutter/cupertino.dart';
import 'package:game_trophy_manager/Model/game_guide_model.dart';
import 'package:game_trophy_manager/Model/game_model.dart';
import 'package:game_trophy_manager/Model/psn_game_snapshot.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class InternalDbProvider extends ChangeNotifier {
  static Database? _db;
  final String dbName = 'Games.db';
  final String myGamesTable = 'MyGames';
  final String myTrophyTable = 'MyTrophy';
  final String psnGamesTable = 'PsnGames';

  final String gameNameColumn = 'GameName';
  final String gameImgUrlColumn = 'GameImgUrl';
  final String trophyNameColumn = 'TrophyName';
  final String trophyImageUrlColumn = 'TrophyImgUrl';
  final String trophyTypeColumn = 'TrophyType';
  final String trophyDescriptionColumn = 'TrophyDescription';
  final String trophyGuideColumn = 'TrophyGuide';
  final String trophyActionColumn = 'TrophyAction';
  final String trophySourceColumn = 'TrophySource';
  final String dateTimeColumn = 'DateTime';
  final String goldColumn = 'GOLD';
  final String silverColumn = 'SILVER';
  final String bronzeColumn = 'BRONZE';
  final String guideEndpointColumn = 'GuideEndpoint';
  final String platformColumn = 'Platform';

  final String psnTitleIdColumn = 'TitleId';
  final String earnedBronzeColumn = 'EarnedBronze';
  final String earnedSilverColumn = 'EarnedSilver';
  final String earnedGoldColumn = 'EarnedGold';
  final String earnedPlatinumColumn = 'EarnedPlatinum';
  final String totalBronzeColumn = 'TotalBronze';
  final String totalSilverColumn = 'TotalSilver';
  final String totalGoldColumn = 'TotalGold';
  final String totalPlatinumColumn = 'TotalPlatinum';
  final String completionPercentColumn = 'CompletionPercent';
  final String lastPlayedAtColumn = 'LastPlayedAt';

  List<GameModel> myGames = <GameModel>[];
  List<GuideModel> myCompletedTrophy = <GuideModel>[];
  List<GuideModel> myStarredTrophy = <GuideModel>[];
  List<PsnGameSnapshot> myPsnGames = <PsnGameSnapshot>[];

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, dbName);
    return openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int newVersion) async {
    await db.execute(
      'CREATE TABLE $myGamesTable('
      '$gameNameColumn TEXT PRIMARY KEY UNIQUE, '
      '$gameImgUrlColumn TEXT, '
      '$dateTimeColumn DATETIME, '
      '$goldColumn TEXT, '
      '$silverColumn TEXT, '
      '$bronzeColumn TEXT, '
      '$guideEndpointColumn TEXT DEFAULT "ps4/guide/", '
      '$platformColumn TEXT DEFAULT "ps4")',
    );
    await db.execute(
      'CREATE TABLE $myTrophyTable('
      '$gameNameColumn TEXT, '
      '$gameImgUrlColumn TEXT, '
      '$trophyNameColumn TEXT, '
      '$trophyImageUrlColumn TEXT, '
      '$trophyTypeColumn TEXT, '
      '$trophyDescriptionColumn TEXT, '
      '$trophyGuideColumn TEXT, '
      '$trophyActionColumn TEXT, '
      '$trophySourceColumn TEXT DEFAULT "local", '
      '$dateTimeColumn DATETIME)',
    );
    await _createPsnGamesTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $myGamesTable ADD COLUMN $guideEndpointColumn TEXT DEFAULT "ps4/guide/"',
      );
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE $myGamesTable ADD COLUMN $platformColumn TEXT DEFAULT "ps4"',
      );
    }
    if (oldVersion < 4) {
      await _createPsnGamesTable(db);
    }
    if (oldVersion < 5) {
      await db.execute(
        'ALTER TABLE $myTrophyTable ADD COLUMN $trophySourceColumn TEXT DEFAULT "local"',
      );
    }
  }

  Future<void> _createPsnGamesTable(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS $psnGamesTable('
      '$psnTitleIdColumn TEXT PRIMARY KEY UNIQUE, '
      '$gameNameColumn TEXT, '
      '$platformColumn TEXT, '
      '$gameImgUrlColumn TEXT, '
      '$earnedBronzeColumn INTEGER, '
      '$earnedSilverColumn INTEGER, '
      '$earnedGoldColumn INTEGER, '
      '$earnedPlatinumColumn INTEGER, '
      '$totalBronzeColumn INTEGER, '
      '$totalSilverColumn INTEGER, '
      '$totalGoldColumn INTEGER, '
      '$totalPlatinumColumn INTEGER, '
      '$completionPercentColumn INTEGER, '
      '$lastPlayedAtColumn TEXT)',
    );
  }

  Future<void> addGameToDb(GameModel game, BuildContext context) async {
    try {
      final dbClient = await db;
      await dbClient.rawInsert(
        'INSERT INTO $myGamesTable('
        '$gameNameColumn, $gameImgUrlColumn, $dateTimeColumn, '
        '$goldColumn, $silverColumn, $bronzeColumn, $guideEndpointColumn, $platformColumn'
        ') VALUES(?, ?, ?, ?, ?, ?, ?, ?)',
        [
          game.gameName,
          game.gameImageUrl,
          DateTime.now().toString(),
          game.gold,
          game.silver,
          game.bronze,
          game.guideEndpoint,
          _normalizePlatform(game.platform),
        ],
      );
      myGames.add(game);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> removeGameFromDb(GameModel game, BuildContext context) async {
    try {
      final dbClient = await db;
      await dbClient.rawDelete(
        'DELETE FROM $myGamesTable WHERE $gameNameColumn = ?',
        [game.gameName],
      );
      myGames.removeWhere((element) => element.gameName == game.gameName);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> getAllGamesFromDb() async {
    try {
      final dbClient = await db;
      final List<Map<String, dynamic>> result =
          await dbClient.rawQuery('SELECT * FROM $myGamesTable');
      myGames = result
          .map(
            (row) => GameModel(
              gameName: row[gameNameColumn] ?? '',
              gameImageUrl: row[gameImgUrlColumn] ?? '',
              gold: row[goldColumn] ?? '0',
              bronze: row[bronzeColumn] ?? '0',
              silver: row[silverColumn] ?? '0',
              guideEndpoint: row[guideEndpointColumn] ?? 'ps4/guide/',
              platform: row[platformColumn] ?? 'ps4',
            ),
          )
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addTrophyToComplete(
    GuideModel guide, {
    String source = 'local',
  }) async {
    try {
      final dbClient = await db;
      await dbClient.delete(
        myTrophyTable,
        where:
            '$gameNameColumn = ? AND $trophyNameColumn = ? AND $trophyActionColumn = ? AND $trophySourceColumn = ?',
        whereArgs: [guide.gameName, guide.trophyName, 'COMPLETED', source],
      );
      await dbClient.rawInsert(
        'INSERT INTO $myTrophyTable('
        '$gameNameColumn, $gameImgUrlColumn, $trophyNameColumn, '
        '$trophyImageUrlColumn, $trophyTypeColumn, $trophyDescriptionColumn, '
        '$trophyGuideColumn, $trophyActionColumn, $trophySourceColumn, $dateTimeColumn'
        ') VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          guide.gameName,
          guide.gameImgUrl,
          guide.trophyName,
          guide.trophyImage,
          guide.trophyType,
          guide.trophyDescription,
          guide.trophyGuide,
          'COMPLETED',
          source,
          DateTime.now().toString(),
        ],
      );
      myCompletedTrophy.removeWhere((element) => _sameGuideIdentity(element, guide));
      myCompletedTrophy.add(guide);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addTrophyToStarred(GuideModel guide) async {
    try {
      final dbClient = await db;
      await dbClient.delete(
        myTrophyTable,
        where:
            '$gameNameColumn = ? AND $trophyNameColumn = ? AND $trophyActionColumn = ?',
        whereArgs: [guide.gameName, guide.trophyName, 'STARRED'],
      );
      await dbClient.rawInsert(
        'INSERT INTO $myTrophyTable('
        '$gameNameColumn, $gameImgUrlColumn, $trophyNameColumn, '
        '$trophyImageUrlColumn, $trophyTypeColumn, $trophyDescriptionColumn, '
        '$trophyGuideColumn, $trophyActionColumn, $trophySourceColumn, $dateTimeColumn'
        ') VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          guide.gameName,
          guide.gameImgUrl,
          guide.trophyName,
          guide.trophyImage,
          guide.trophyType,
          guide.trophyDescription,
          guide.trophyGuide,
          'STARRED',
          'local',
          DateTime.now().toString(),
        ],
      );
      myStarredTrophy.removeWhere((element) => _sameGuideIdentity(element, guide));
      myStarredTrophy.add(guide);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> removeTrophyFromComplete(GuideModel guide) async {
    try {
      final dbClient = await db;
      await dbClient.rawDelete(
        'DELETE FROM $myTrophyTable WHERE $gameNameColumn = ? AND $trophyNameColumn = ? AND $trophyActionColumn = ?',
        [guide.gameName, guide.trophyName, 'COMPLETED'],
      );
      myCompletedTrophy.removeWhere((element) => _sameGuideIdentity(element, guide));
      notifyListeners();
    } catch (_) {}
  }

  Future<void> removeTrophyFromStarred(GuideModel guide) async {
    try {
      final dbClient = await db;
      await dbClient.rawDelete(
        'DELETE FROM $myTrophyTable WHERE $gameNameColumn = ? AND $trophyNameColumn = ? AND $trophyActionColumn = ?',
        [guide.gameName, guide.trophyName, 'STARRED'],
      );
      myStarredTrophy.removeWhere((element) => _sameGuideIdentity(element, guide));
      notifyListeners();
    } catch (_) {}
  }

  Future<void> getAllTrophiesFromDb() async {
    try {
      final dbClient = await db;
      final List<Map<String, dynamic>> result = await dbClient.rawQuery(
        'SELECT * FROM $myTrophyTable ORDER BY $dateTimeColumn DESC',
      );
      myCompletedTrophy = <GuideModel>[];
      myStarredTrophy = <GuideModel>[];
      for (final row in result) {
        final GuideModel guide = GuideModel(
          trophyDescription: row[trophyDescriptionColumn] ?? '',
          trophyGuide: row[trophyGuideColumn] ?? '',
          trophyImage: row[trophyImageUrlColumn] ?? '',
          trophyName: row[trophyNameColumn] ?? '',
          trophyType: row[trophyTypeColumn] ?? '',
          gameImgUrl: row[gameImgUrlColumn] ?? '',
          gameName: row[gameNameColumn] ?? '',
          isCompleted: row[trophyActionColumn] == 'COMPLETED',
          isStarred: row[trophyActionColumn] == 'STARRED',
        );
        if (guide.isCompleted) {
          myCompletedTrophy.add(guide);
        } else {
          myStarredTrophy.add(guide);
        }
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> getAllPsnGamesFromDb() async {
    try {
      final dbClient = await db;
      final List<Map<String, dynamic>> result =
          await dbClient.rawQuery('SELECT * FROM $psnGamesTable');
      myPsnGames = result.map((row) => PsnGameSnapshot.fromDb(row)).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> replacePsnGamesSnapshot(List<PsnGameSnapshot> games) async {
    final dbClient = await db;
    await dbClient.transaction((txn) async {
      await txn.delete(psnGamesTable);
      for (final game in games) {
        await txn.insert(
          psnGamesTable,
          game.toDbMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
    myPsnGames = List<PsnGameSnapshot>.from(games);
    notifyListeners();
  }

  Future<void> replacePsnCompletedTrophies(List<GuideModel> trophies) async {
    final dbClient = await db;
    await dbClient.transaction((txn) async {
      await txn.delete(
        myTrophyTable,
        where: '$trophyActionColumn = ? AND $trophySourceColumn = ?',
        whereArgs: ['COMPLETED', 'psn'],
      );

      final existingCompletedRows = await txn.query(
        myTrophyTable,
        columns: [gameNameColumn, trophyNameColumn],
        where: '$trophyActionColumn = ?',
        whereArgs: ['COMPLETED'],
      );
      final existingKeys = existingCompletedRows
          .map((row) => _guideKey(row[gameNameColumn], row[trophyNameColumn]))
          .toSet();

      for (final trophy in trophies) {
        final trophyKey = _guideKey(trophy.gameName, trophy.trophyName);
        if (existingKeys.contains(trophyKey)) continue;

        await txn.insert(
          myTrophyTable,
          {
            gameNameColumn: trophy.gameName,
            gameImgUrlColumn: trophy.gameImgUrl,
            trophyNameColumn: trophy.trophyName,
            trophyImageUrlColumn: trophy.trophyImage,
            trophyTypeColumn: trophy.trophyType,
            trophyDescriptionColumn: trophy.trophyDescription,
            trophyGuideColumn: trophy.trophyGuide,
            trophyActionColumn: 'COMPLETED',
            trophySourceColumn: 'psn',
            dateTimeColumn: DateTime.now().toIso8601String(),
          },
        );
        existingKeys.add(trophyKey);
      }
    });

    await getAllTrophiesFromDb();
  }

  Future<void> upsertGamesFromSync(List<GameModel> games) async {
    if (games.isEmpty) return;

    final dbClient = await db;
    await dbClient.transaction((txn) async {
      for (final game in games) {
        await txn.insert(
          myGamesTable,
          {
            gameNameColumn: game.gameName,
            gameImgUrlColumn: game.gameImageUrl,
            dateTimeColumn: DateTime.now().toIso8601String(),
            goldColumn: game.gold,
            silverColumn: game.silver,
            bronzeColumn: game.bronze,
            guideEndpointColumn: game.guideEndpoint,
            platformColumn: _normalizePlatform(game.platform),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });

    final Map<String, GameModel> merged = {
      for (final game in myGames) game.gameName: game,
    };
    for (final game in games) {
      merged[game.gameName] = game;
    }
    myGames = merged.values.toList()
      ..sort((a, b) =>
          a.gameName.toLowerCase().compareTo(b.gameName.toLowerCase()));
    notifyListeners();
  }

  Future<void> clearPsnGamesSnapshot() async {
    final dbClient = await db;
    await dbClient.delete(psnGamesTable);
    myPsnGames = <PsnGameSnapshot>[];
    notifyListeners();
  }

  Future<void> clearPsnCompletedTrophies() async {
    final dbClient = await db;
    await dbClient.delete(
      myTrophyTable,
      where: '$trophyActionColumn = ? AND $trophySourceColumn = ?',
      whereArgs: ['COMPLETED', 'psn'],
    );
    await getAllTrophiesFromDb();
  }

  bool hasCompletedTrophy(String gameName, String trophyName) {
    final targetKey = _guideKey(gameName, trophyName);
    return myCompletedTrophy.any(
      (guide) => _guideKey(guide.gameName, guide.trophyName) == targetKey,
    );
  }

  bool hasStarredTrophy(String gameName, String trophyName) {
    final targetKey = _guideKey(gameName, trophyName);
    return myStarredTrophy.any(
      (guide) => _guideKey(guide.gameName, guide.trophyName) == targetKey,
    );
  }

  String _normalizePlatform(String platform) {
    final normalized = platform.toLowerCase();
    if (normalized.contains('5')) return 'ps5';
    return 'ps4';
  }

  bool _sameGuideIdentity(GuideModel left, GuideModel right) {
    return _guideKey(left.gameName, left.trophyName) ==
        _guideKey(right.gameName, right.trophyName);
  }

  String _guideKey(dynamic gameName, dynamic trophyName) {
    final normalizedGame = _normalizeText(gameName);
    final normalizedTrophy = _normalizeText(trophyName);
    return '$normalizedGame::$normalizedTrophy';
  }

  String _normalizeText(dynamic value) {
    return (value ?? '')
        .toString()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}
