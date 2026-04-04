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
}
