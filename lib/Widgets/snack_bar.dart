import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';

Widget snackBar(
    BuildContext context, String title, String subtitle, double wp) {
  return new Flushbar(
    boxShadows: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 20.0, // soften the shadow
        spreadRadius: 2.0, //extend the shadow
        offset: Offset(
          5.0, // Move to right 10  horizontally
          5.0, // Move to bottom 10 Vertically
        ),
      )
    ],
    maxWidth: wp * 0.8,
    borderRadius: BorderRadius.circular(5.0),
    backgroundGradient: LinearGradient(
        colors: [primaryAccentColor, secondaryAccentColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter),
    icon: Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Image(
        height: 50,
        image: AssetImage('images/drawer_image.png'),
      ),
    ),
    titleText: Text(
      title,
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    messageText: Text(
      subtitle,
      overflow: TextOverflow.clip,
      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w400),
    ),
    duration: Duration(seconds: 3),
  )..show(context);
}
