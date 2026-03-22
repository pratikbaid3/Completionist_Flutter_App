import 'package:flutter/material.dart';

// Core dark palette - deep space gamer aesthetic
const Color primaryColor = Color(0xff0D1117);
const Color secondaryColor = Color(0xff161B22);
const Color surfaceColor = Color(0xff1C2333);
const Color cardColor = Color(0xff21283B);
const Color shadowColor = Color(0xff0A0E14);

// Neon accent system
const Color primaryAccentColor = Color(0xff7C3AED); // Vivid purple
const Color secondaryAccentColor = Color(0xff06B6D4); // Cyan
const Color neonGreen = Color(0xff10B981); // Success / completed
const Color neonPink = Color(0xffF472B6); // Highlights
const Color neonBlue = Color(0xff3B82F6); // Links / info

// Trophy tier colors (enhanced with glow-ready variants)
const Color goldenColor = Color(0xffFFD700);
const Color silverColor = Color(0xffC0C0C0);
const Color bronzeColor = Color(0xffCD7F32);
const Color platinumColor = Color(0xffE5E4E2);

// Text hierarchy
const Color textPrimary = Color(0xffF0F6FC);
const Color textSecondary = Color(0xff8B949E);
const Color textMuted = Color(0xff484F58);

// Gradients
const LinearGradient accentGradient = LinearGradient(
  colors: [primaryAccentColor, secondaryAccentColor],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient cardGradient = LinearGradient(
  colors: [Color(0xff1C2333), Color(0xff161B22)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient glowGradient = LinearGradient(
  colors: [Color(0xff7C3AED), Color(0xff06B6D4), Color(0xff10B981)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Glassmorphism helpers
BoxDecoration glassDecoration({
  double borderRadius = 16,
  double opacity = 0.08,
  Color? borderColor,
}) {
  return BoxDecoration(
    color: Colors.white.withValues(alpha: opacity),
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(
      color: borderColor ?? Colors.white.withValues(alpha: 0.1),
      width: 1,
    ),
  );
}

BoxDecoration neonCardDecoration({
  Color glowColor = primaryAccentColor,
  double borderRadius = 16,
}) {
  return BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(
      color: glowColor.withValues(alpha: 0.3),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: glowColor.withValues(alpha: 0.15),
        blurRadius: 20,
        spreadRadius: -2,
      ),
      BoxShadow(
        color: shadowColor.withValues(alpha: 0.5),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );
}

Color trophyColor(String trophyType) {
  switch (trophyType.toUpperCase()) {
    case 'GOLD':
      return goldenColor;
    case 'SILVER':
      return silverColor;
    case 'BRONZE':
      return bronzeColor;
    case 'PLATINUM':
      return platinumColor;
    default:
      return goldenColor;
  }
}
