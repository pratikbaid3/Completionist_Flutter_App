import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:google_fonts/google_fonts.dart';

Widget snackBar(
    BuildContext context, String title, String subtitle, double wp) {
  return Flushbar(
    margin: EdgeInsets.symmetric(horizontal: wp * 0.05, vertical: 12),
    borderRadius: BorderRadius.circular(14),
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    backgroundColor: surfaceColor,
    borderColor: primaryAccentColor.withValues(alpha: 0.2),
    boxShadows: [
      BoxShadow(
        color: primaryAccentColor.withValues(alpha: 0.15),
        blurRadius: 20,
        offset: Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 10,
        offset: Offset(0, 2),
      ),
    ],
    icon: Container(
      margin: EdgeInsets.only(left: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'images/app_icon.png',
          width: 36,
          height: 36,
          fit: BoxFit.cover,
        ),
      ),
    ),
    titleText: Text(
      title,
      style: GoogleFonts.inter(
        color: textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    ),
    messageText: Text(
      subtitle,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      style: TextStyle(
        color: textSecondary,
        fontWeight: FontWeight.w400,
        fontSize: 12,
      ),
    ),
    duration: Duration(seconds: 3),
    flushbarPosition: FlushbarPosition.TOP,
    animationDuration: Duration(milliseconds: 400),
  )..show(context);
}
