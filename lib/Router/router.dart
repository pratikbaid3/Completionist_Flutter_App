import 'package:flutter/material.dart';
import 'package:game_trophy_manager/Pages/dashboard.dart';
import 'package:game_trophy_manager/Pages/nav_drawer.dart';
import 'package:game_trophy_manager/Pages/splash_page.dart';
import 'package:game_trophy_manager/Provider/game_provider.dart';
import 'package:game_trophy_manager/Router/router_constant.dart';
import 'package:provider/provider.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case splashScreenRoute:
      return MaterialPageRoute(builder: (context) => SplashScreen());
      break;
    case dashboardRoute:
      return MaterialPageRoute(builder: (context) => Dashboard());
      break;
    case homePageRoute:
      return MaterialPageRoute(
        builder: (context) => MultiProvider(
          providers: [
            ChangeNotifierProvider<GameProvider>(
              create: (context) => GameProvider(),
            )
          ],
          child: NavDrawerPage(),
        ),
      );
      break;
  }
}