import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:game_trophy_manager/Provider/internal_db_provider.dart';
import 'package:game_trophy_manager/Router/router_constant.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    initializeData();
    toDashboard();
  }

  void initializeData() {
    Provider.of<InternalDbProvider>(context, listen: false).getAllGamesFromDb();
    Provider.of<InternalDbProvider>(context, listen: false)
        .getAllTrophiesFromDb();
  }

  void toDashboard() {
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.of(context).popAndPushNamed(homePageRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events,
              size: 100,
              color: primaryAccentColor,
            ),
            SizedBox(height: 30),
            SpinKitFadingCircle(
              color: primaryAccentColor,
              size: 50.0,
            ),
          ],
        ),
      ),
    );
  }
}
