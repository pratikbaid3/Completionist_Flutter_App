import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_trophy_manager/BloC/Game/game_bloc.dart';
import 'package:game_trophy_manager/Pages/login_page.dart';
import 'package:game_trophy_manager/Pages/signup_page.dart';
import 'package:game_trophy_manager/Pages/test.dart';
import 'package:game_trophy_manager/Utilities/game_data_manager.dart';
import 'Pages/game_page.dart';
import 'Pages/onboarding_page.dart';
import 'Pages/splash_page.dart';
import 'Pages/home_page.dart';
import 'Utilities/reusable_elements.dart';

void main() {
  runApp(OnBoarding());
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class OnBoarding extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc(GameData()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
            primaryColor: backgroundColor,
            scaffoldBackgroundColor: backgroundColor,
            accentColor: backgroundColor),
        initialRoute: '/SplashScreen',
        routes: {
          '/OnBoardingPage': (context) => OnBoardingPage(),
          '/SignupPage': (context) => SignupPage(),
          '/LoginPage': (context) => LoginPage(),
          '/GamePage': (context) => GamePage(),
          '/SplashScreen': (context) => SplashScreen(),
          '/HomePage': (context) => HomePage(),
          '/TestPage': (context) => TestPage()
        },
      ),
    );
  }
}
