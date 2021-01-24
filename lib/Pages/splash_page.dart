import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:game_trophy_manager/Provider/graph_provider.dart';
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
    Provider.of<GraphProvider>(context, listen: false).getAllTrophyDateFromDb();
  }

  void toDashboard() {
    new Future.delayed(const Duration(seconds: 4), () {
      Navigator.of(context).popAndPushNamed(homePageRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: FlareActor("assets/anim2.flr",
            alignment: Alignment.center,
            fit: BoxFit.scaleDown,
            animation: "Alarm"),
      ),
    );
  }
}
