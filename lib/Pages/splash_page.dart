import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import '../Utilities/external_db_helper.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    External_Database_Manager manager = new External_Database_Manager();
    manager.Transfer_Data();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void getUser() async {
    try {
      Navigator.popAndPushNamed(context, '/TestPage');
    } catch (e) {
      //print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    new Future.delayed(const Duration(seconds: 4), () {
      getUser();
    });

    return Scaffold(
      body: Center(
        child: FlareActor("assets/anim.flr",
            alignment: Alignment.center,
            fit: BoxFit.contain,
            animation: "idle"),
      ),
    );
  }
}
