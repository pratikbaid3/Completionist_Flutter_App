import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AllXboxGamesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: neonGreen.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: neonGreen.withValues(alpha: 0.1),
                    blurRadius: 30,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Icon(
                FontAwesomeIcons.xbox,
                size: 56,
                color: neonGreen,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(
                  begin: Offset(0.8, 0.8),
                  end: Offset(1.0, 1.0),
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                ),
            SizedBox(height: 32),
            Text(
              'COMING SOON',
              style: GoogleFonts.orbitron(
                color: textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 22,
                letterSpacing: 4,
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 500.ms)
                .slideY(begin: 0.3, end: 0, delay: 300.ms, duration: 500.ms),
            SizedBox(height: 12),
            Text(
              'Xbox achievement guides are\non their way',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textSecondary,
                fontSize: 15,
                height: 1.5,
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 500.ms),
          ],
        ),
      ),
    );
  }
}
