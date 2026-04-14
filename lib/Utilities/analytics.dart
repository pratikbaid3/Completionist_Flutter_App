import 'package:firebase_analytics/firebase_analytics.dart';

class Analytics {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // Screen views
  static Future<void> logScreenView(String screenName) {
    return _analytics.logScreenView(screenName: screenName);
  }

  // Tab navigation
  static Future<void> logTabSwitch(String tabName) {
    return _analytics.logEvent(
      name: 'tab_switch',
      parameters: {'tab_name': tabName},
    );
  }

  // Game browsing
  static Future<void> logViewGame(String gameName, String platform) {
    return _analytics.logEvent(
      name: 'view_game',
      parameters: {'game_name': gameName, 'platform': platform},
    );
  }

  static Future<void> logAddGame(String gameName) {
    return _analytics.logEvent(
      name: 'add_game',
      parameters: {'game_name': gameName},
    );
  }

  static Future<void> logRemoveGame(String gameName) {
    return _analytics.logEvent(
      name: 'remove_game',
      parameters: {'game_name': gameName},
    );
  }

  // Trophy actions
  static Future<void> logCompleteTrophy(String trophyName, String gameName) {
    return _analytics.logEvent(
      name: 'complete_trophy',
      parameters: {'trophy_name': trophyName, 'game_name': gameName},
    );
  }

  static Future<void> logUncompleteTrophy(String trophyName, String gameName) {
    return _analytics.logEvent(
      name: 'uncomplete_trophy',
      parameters: {'trophy_name': trophyName, 'game_name': gameName},
    );
  }

  static Future<void> logStarTrophy(String trophyName, String gameName) {
    return _analytics.logEvent(
      name: 'star_trophy',
      parameters: {'trophy_name': trophyName, 'game_name': gameName},
    );
  }

  static Future<void> logUnstarTrophy(String trophyName, String gameName) {
    return _analytics.logEvent(
      name: 'unstar_trophy',
      parameters: {'trophy_name': trophyName, 'game_name': gameName},
    );
  }

  // Search
  static Future<void> logSearch(String query, String platform) {
    return _analytics.logSearch(
      searchTerm: query,
      parameters: {'platform': platform},
    );
  }

  // Filter
  static Future<void> logFilter(String filterType, String gameName) {
    return _analytics.logEvent(
      name: 'filter_trophies',
      parameters: {'filter_type': filterType, 'game_name': gameName},
    );
  }

  // Guide interaction
  static Future<void> logExpandGuide(String trophyName, String gameName) {
    return _analytics.logEvent(
      name: 'expand_guide',
      parameters: {'trophy_name': trophyName, 'game_name': gameName},
    );
  }

  // Browse games button from empty dashboard
  static Future<void> logBrowseGames() {
    return _analytics.logEvent(name: 'browse_games_cta');
  }

  // PSN flow
  static Future<void> logPsnLoginOpened() {
    return _analytics.logEvent(name: 'psn_login_opened');
  }

  static Future<void> logPsnLoginInfoOpened({required bool isConnected}) {
    return _analytics.logEvent(
      name: 'psn_login_info_opened',
      parameters: {'is_connected': _flag(isConnected)},
    );
  }

  static Future<void> logPsnLoginStepOpened(String step) {
    return _analytics.logEvent(
      name: 'psn_login_step_opened',
      parameters: {'step': step},
    );
  }

  static Future<void> logPsnTokenImportAttempt({
    required String source,
    required bool foundToken,
  }) {
    return _analytics.logEvent(
      name: 'psn_token_import_attempt',
      parameters: {
        'source': source,
        'found_token': _flag(foundToken),
      },
    );
  }

  static Future<void> logPsnConnectSubmitted({required String source}) {
    return _analytics.logEvent(
      name: 'psn_connect_submitted',
      parameters: {'source': source},
    );
  }

  static Future<void> logPsnConnectStarted({required String method}) {
    return _analytics.logEvent(
      name: 'psn_connect_started',
      parameters: {'method': method},
    );
  }

  static Future<void> logPsnConnectSuccess({required String syncStatus}) {
    return _analytics.logEvent(
      name: 'psn_connect_success',
      parameters: {'sync_status': syncStatus},
    );
  }

  static Future<void> logPsnConnectFailed({required String reason}) {
    return _analytics.logEvent(
      name: 'psn_connect_failed',
      parameters: {'reason': _sanitizeReason(reason)},
    );
  }

  static Future<void> logPsnSyncStarted({
    required String trigger,
    required bool forceSync,
    required bool manageBusy,
  }) {
    return _analytics.logEvent(
      name: 'psn_sync_started',
      parameters: {
        'trigger': trigger,
        'force_sync': _flag(forceSync),
        'manage_busy': _flag(manageBusy),
      },
    );
  }

  static Future<void> logPsnSyncSuccess({
    required String trigger,
    required bool forceSync,
    required int libraryCount,
    required int matchedGames,
    required int dedupedGames,
    required int completedTrophies,
  }) {
    return _analytics.logEvent(
      name: 'psn_sync_success',
      parameters: {
        'trigger': trigger,
        'force_sync': _flag(forceSync),
        'library_count': libraryCount,
        'matched_games': matchedGames,
        'deduped_games': dedupedGames,
        'completed_trophies': completedTrophies,
      },
    );
  }

  static Future<void> logPsnSyncFailed({
    required String trigger,
    required bool forceSync,
    required String reason,
  }) {
    return _analytics.logEvent(
      name: 'psn_sync_failed',
      parameters: {
        'trigger': trigger,
        'force_sync': _flag(forceSync),
        'reason': _sanitizeReason(reason),
      },
    );
  }

  static Future<void> logPsnSyncBlockedNoSession({required String trigger}) {
    return _analytics.logEvent(
      name: 'psn_sync_blocked_no_session',
      parameters: {'trigger': trigger},
    );
  }

  static Future<void> logPsnDisconnect({
    required bool hadProfile,
    required bool hadLastSync,
    required int cachedGames,
  }) {
    return _analytics.logEvent(
      name: 'psn_disconnect',
      parameters: {
        'had_profile': _flag(hadProfile),
        'had_last_sync': _flag(hadLastSync),
        'cached_games': cachedGames,
      },
    );
  }

  static int _flag(bool value) => value ? 1 : 0;

  static String _sanitizeReason(String reason) {
    final normalized = reason.trim();
    if (normalized.isEmpty) return 'unknown';
    if (normalized.length <= 100) return normalized;
    return normalized.substring(0, 100);
  }
}
