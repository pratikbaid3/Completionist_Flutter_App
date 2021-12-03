import 'package:flutter/material.dart';
import 'package:game_trophy_manager/Pages/PS4/ps4_games_page.dart';
import 'package:game_trophy_manager/Pages/Store/store_page.dart';
import 'package:game_trophy_manager/Pages/dashboard.dart';
import 'package:game_trophy_manager/Pages/PS4/ps4_guide_page.dart';
import 'package:game_trophy_manager/Pages/nav_drawer.dart';
import 'package:game_trophy_manager/Pages/splash_page.dart';
import 'package:game_trophy_manager/Router/router_constant.dart';
import 'package:game_trophy_manager/Widgets/app_bar.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  final args = settings.arguments;
  switch (settings.name) {
    case splashScreenRoute:
      return MaterialPageRoute(builder: (context) => SplashScreen());
      break;
    case dashboardRoute:
      return MaterialPageRoute(builder: (context) => Dashboard());
      break;
    case homePageRoute:
      return MaterialPageRoute(
        builder: (context) => NavDrawerPage(),
      );
      break;
    case guidePageRoute:
      return MaterialPageRoute(
        builder: (context) => Ps4GuidePage(game: args),
      );
      break;
    case ps4GamePageRoute:
      return MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: BaseAppBar(
            appBar: AppBar(),
          ),
          body: AllPS4GamesPage(),
        ),
      );
      break;
    case storePageRoute:
      return MaterialPageRoute(
        builder: (context) => StorePage(),
      );
      break;
    // default:
    //   return MaterialPageRoute(builder: (context) => NavDrawerPage());
    //   break;
  }
}
