import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _openCountKey = 'app_open_count';
const String _promptCountKey = 'review_prompt_count';
const String _reviewDoneKey = 'review_completed';

/// Call this on app launch.
/// - First prompt at 3rd open
/// - If skipped/dismissed, prompt again after 2 more opens (5th open)
/// - If skipped again, prompt one last time after 2 more opens (7th open)
/// - After 3 prompts total, never prompt again
Future<void> checkAndShowReview(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();

  // In debug mode, always show the dialog
  if (kDebugMode) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => _ReviewDialog(
        onReviewDone: () async {},
      ),
    );
    return;
  }

  // If user already submitted a review, never show again
  final reviewDone = prefs.getBool(_reviewDoneKey) ?? false;
  if (reviewDone) return;

  // If already prompted 3 times, stop
  final promptCount = prefs.getInt(_promptCountKey) ?? 0;
  if (promptCount >= 3) return;

  int openCount = (prefs.getInt(_openCountKey) ?? 0) + 1;
  await prefs.setInt(_openCountKey, openCount);

  // First prompt at open 3, then every 2 opens after that
  final triggerAt = 3 + (promptCount * 2); // 3, 5, 7

  if (openCount >= triggerAt && context.mounted) {
    await prefs.setInt(_promptCountKey, promptCount + 1);
    // Reset open count so next prompt is 2 opens from now
    await prefs.setInt(_openCountKey, triggerAt);

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => _ReviewDialog(
        onReviewDone: () async {
          await prefs.setBool(_reviewDoneKey, true);
        },
      ),
    );
  }
}

class _ReviewDialog extends StatefulWidget {
  final Future<void> Function() onReviewDone;
  const _ReviewDialog({required this.onReviewDone});

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  int _selectedStars = 0;
  bool _showThankYou = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primaryAccentColor.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryAccentColor.withValues(alpha: 0.1),
              blurRadius: 30,
              spreadRadius: -5,
            ),
          ],
        ),
        child: _showThankYou ? _buildThankYou() : _buildRating(),
      ),
    );
  }

  Widget _buildRating() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'images/app_icon.png',
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Enjoying Completionist?',
          style: GoogleFonts.inter(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Rate your experience so far',
          style: TextStyle(color: textSecondary, fontSize: 14),
        ),
        SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starNum = index + 1;
            return GestureDetector(
              onTap: () => setState(() => _selectedStars = starNum),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: AnimatedScale(
                  scale: _selectedStars >= starNum ? 1.2 : 1.0,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    _selectedStars >= starNum
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 40,
                    color: _selectedStars >= starNum ? goldenColor : textMuted,
                  ),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: AnimatedOpacity(
            opacity: _selectedStars > 0 ? 1.0 : 0.4,
            duration: Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: _selectedStars > 0 ? _onSubmit : null,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: _selectedStars > 0 ? accentGradient : null,
                  color: _selectedStars > 0 ? null : textMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'SUBMIT',
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            'Maybe later',
            style: TextStyle(color: textMuted, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Future<void> _onSubmit() async {
    await widget.onReviewDone();

    if (_selectedStars == 5) {
      Navigator.pop(context);
      try {
        final inAppReview = InAppReview.instance;
        if (await inAppReview.isAvailable()) {
          await inAppReview.requestReview();
        } else {
          await inAppReview.openStoreListing(
            appStoreId: 'co.turingcreatives.game_trophy_manager',
          );
        }
      } catch (_) {
        // Silently fail on simulator / unsupported platforms
      }
    } else {
      setState(() => _showThankYou = true);
    }
  }

  Widget _buildThankYou() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: neonGreen.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_circle_rounded, size: 40, color: neonGreen),
        ),
        SizedBox(height: 16),
        Text(
          'Thank you!',
          style: GoogleFonts.inter(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Your feedback has been recorded.\nWe\'ll use it to improve your experience.',
          textAlign: TextAlign.center,
          style: TextStyle(color: textSecondary, fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: accentGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'DONE',
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
