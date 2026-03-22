import 'package:flutter/material.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBar appBar;
  final String? title;
  final List<Widget>? actions;

  const BaseAppBar({
    Key? key,
    required this.appBar,
    this.title,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: primaryColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: title != null
          ? Text(
              title!,
              style: GoogleFonts.orbitron(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
                letterSpacing: 2,
              ),
            )
          : null,
      actions: actions,
      iconTheme: IconThemeData(color: textPrimary),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                primaryAccentColor.withValues(alpha: 0.3),
                secondaryAccentColor.withValues(alpha: 0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height + 1);
}
