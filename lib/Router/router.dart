import 'package:flutter/material.dart';
import 'package:game_trophy_manager/Pages/PS4/ps4_games_page.dart';
import 'package:game_trophy_manager/Pages/Store/store_page.dart';
import 'package:game_trophy_manager/Pages/dashboard.dart';
import 'package:game_trophy_manager/Pages/PS4/ps4_guide_page.dart';
import 'package:game_trophy_manager/Pages/nav_drawer.dart';
import 'package:game_trophy_manager/Pages/splash_page.dart';
import 'package:game_trophy_manager/Router/router_constant.dart';
import 'package:game_trophy_manager/Widgets/app_bar.dart';
import 'package:game_trophy_manager/Model/game_model.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:game_trophy_manager/Widgets/aurora_background.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  final args = settings.arguments;
  switch (settings.name) {
    case splashScreenRoute:
      return _fadeRoute(SplashScreen(), settings);
    case dashboardRoute:
      return _slideRoute(Dashboard(), settings);
    case homePageRoute:
      return _fadeRoute(NavDrawerPage(), settings);
    case guidePageRoute:
      if (args is Map<String, dynamic>) {
        return _slideRoute(
          Ps4GuidePage(
            game: args['game'] as GameModel,
            guideEndpoint: args['guideEndpoint'] as String? ?? 'ps4/guide/',
          ),
          settings,
        );
      }
      return _slideRoute(
        Ps4GuidePage(game: args as GameModel),
        settings,
      );
    case ps4GamePageRoute:
      return _slideRoute(
        Scaffold(
          backgroundColor: primaryColor,
          appBar: BaseAppBar(
            appBar: AppBar(),
            title: 'BROWSE',
          ),
          body: AuroraBackground(child: AllPS4GamesPage()),
        ),
        settings,
      );
    case storePageRoute:
      return _slideUpRoute(StorePage(), settings);
    default:
      return _fadeRoute(NavDrawerPage(), settings);
  }
}

// Smooth fade transition
PageRouteBuilder _fadeRoute(Widget page, RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: Duration(milliseconds: 350),
    reverseTransitionDuration: Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: child,
      );
    },
  );
}

// Slide from right transition
PageRouteBuilder _slideRoute(Widget page, RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: Duration(milliseconds: 350),
    reverseTransitionDuration: Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      ));

      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ));

      return SlideTransition(
        position: offsetAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    },
  );
}

// Slide up transition (for modals like store)
PageRouteBuilder _slideUpRoute(Widget page, RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: Duration(milliseconds: 400),
    reverseTransitionDuration: Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: Offset(0.0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ));

      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Interval(0.0, 0.6, curve: Curves.easeIn),
      ));

      return SlideTransition(
        position: offsetAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    },
  );
}
