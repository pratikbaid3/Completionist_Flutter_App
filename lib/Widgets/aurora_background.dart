import 'dart:math';
import 'package:flutter/material.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';

class AuroraBackground extends StatefulWidget {
  final Widget child;
  const AuroraBackground({required this.child, Key? key}) : super(key: key);

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value * 2 * pi;
        return Stack(
          children: [
            // Background color
            Positioned.fill(
              child: Container(color: primaryColor),
            ),
            // Blob 1 - purple
            Positioned(
              left: size.width * 0.15 + sin(t) * size.width * 0.12,
              top: size.height * 0.2 + cos(t * 0.7) * size.height * 0.08,
              child: _AuroraBlob(
                diameter: size.width * 0.8,
                color: primaryAccentColor,
                opacity: 0.07,
              ),
            ),
            // Blob 2 - cyan
            Positioned(
              right: size.width * 0.1 + cos(t * 0.8) * size.width * 0.1,
              bottom: size.height * 0.18 + sin(t * 0.6) * size.height * 0.1,
              child: _AuroraBlob(
                diameter: size.width * 0.75,
                color: secondaryAccentColor,
                opacity: 0.06,
              ),
            ),
            // Blob 3 - green
            Positioned(
              left: size.width * 0.35 + cos(t * 0.5) * size.width * 0.15,
              bottom: size.height * 0.35 + sin(t * 0.9) * size.height * 0.06,
              child: _AuroraBlob(
                diameter: size.width * 0.65,
                color: neonGreen,
                opacity: 0.04,
              ),
            ),
            // Blob 4 - pink
            Positioned(
              right: size.width * 0.05 + sin(t * 1.1) * size.width * 0.08,
              top: size.height * 0.08 + cos(t * 0.5) * size.height * 0.06,
              child: _AuroraBlob(
                diameter: size.width * 0.6,
                color: neonPink,
                opacity: 0.05,
              ),
            ),
            // Blob 5 - blue
            Positioned(
              left: -size.width * 0.1 + cos(t * 0.9) * size.width * 0.1,
              bottom: size.height * 0.05 + sin(t * 0.4) * size.height * 0.07,
              child: _AuroraBlob(
                diameter: size.width * 0.7,
                color: neonBlue,
                opacity: 0.05,
              ),
            ),
            // Blob 6 - purple small
            Positioned(
              right: size.width * 0.2 + sin(t * 1.3) * size.width * 0.06,
              top: size.height * 0.45 + cos(t * 0.7) * size.height * 0.05,
              child: _AuroraBlob(
                diameter: size.width * 0.45,
                color: primaryAccentColor,
                opacity: 0.04,
              ),
            ),
            // Child content on top
            Positioned.fill(child: widget.child),
          ],
        );
      },
    );
  }
}

class _AuroraBlob extends StatelessWidget {
  final double diameter;
  final Color color;
  final double opacity;

  const _AuroraBlob({
    required this.diameter,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: opacity * 0.3),
            Colors.transparent,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
