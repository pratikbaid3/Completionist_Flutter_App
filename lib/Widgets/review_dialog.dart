import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Pref keys
const String _promptCountKey = 'review_prompt_count';
const String _reviewDoneKey = 'review_completed';
const String _lastPromptDateKey = 'review_last_prompt_date';
const String _dismissCountKey = 'review_dismiss_count';

// Prevents multiple prompts in the same session
bool _promptedThisSession = false;

/// Trigger types that indicate user satisfaction
enum ReviewTrigger {
  trophyMilestone, // 5th, 10th, 20th trophy completed
  gameMilestone, // 3rd, 5th game added
  appOpenFallback, // 7th app open (fallback)
}

/// Call this from satisfaction events (trophy complete, game added).
/// It decides whether to show the prompt based on milestones and cooldowns.
Future<void> maybeShowReview(
  BuildContext context,
  ReviewTrigger trigger, {
  int? totalCompleted,
  int? totalGames,
}) async {
  if (_promptedThisSession) return;

  final prefs = await SharedPreferences.getInstance();

  // In debug mode, always show
  if (kDebugMode) {
    if (!context.mounted) return;
    _promptedThisSession = true;
    _showReviewDialog(context, prefs);
    return;
  }

  // If user already submitted a review, never show again
  if (prefs.getBool(_reviewDoneKey) ?? false) return;

  // Max 3 prompts ever
  final promptCount = prefs.getInt(_promptCountKey) ?? 0;
  if (promptCount >= 3) return;

  // User tapped "Maybe later" twice → stop forever
  final dismissCount = prefs.getInt(_dismissCountKey) ?? 0;
  if (dismissCount >= 2) return;

  // Minimum 7 days between prompts
  final lastPromptDate = prefs.getString(_lastPromptDateKey);
  if (lastPromptDate != null) {
    final lastDate = DateTime.tryParse(lastPromptDate);
    if (lastDate != null && DateTime.now().difference(lastDate).inDays < 7) {
      return;
    }
  }

  // Check if this trigger qualifies
  bool shouldPrompt = false;
  switch (trigger) {
    case ReviewTrigger.trophyMilestone:
      if (totalCompleted != null &&
          (totalCompleted == 5 || totalCompleted == 10 || totalCompleted == 20)) {
        shouldPrompt = true;
      }
      break;
    case ReviewTrigger.gameMilestone:
      if (totalGames != null && (totalGames == 3 || totalGames == 5)) {
        shouldPrompt = true;
      }
      break;
    case ReviewTrigger.appOpenFallback:
      // Only use fallback if no satisfaction trigger has fired yet
      if (promptCount == 0) {
        final openCount = (prefs.getInt('app_open_count') ?? 0) + 1;
        await prefs.setInt('app_open_count', openCount);
        if (openCount >= 7) shouldPrompt = true;
      }
      break;
  }

  if (!shouldPrompt || !context.mounted) return;

  _promptedThisSession = true;

  // Delay 3 seconds after the satisfaction event to let the dopamine settle
  await Future.delayed(Duration(seconds: 3));
  if (!context.mounted) return;

  _showReviewDialog(context, prefs);
}

void _showReviewDialog(BuildContext context, SharedPreferences prefs) {
  showDialog(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (_) => _ReviewDialog(
      onReviewDone: () async {
        await prefs.setBool(_reviewDoneKey, true);
      },
      onPromptShown: () async {
        final count = (prefs.getInt(_promptCountKey) ?? 0) + 1;
        await prefs.setInt(_promptCountKey, count);
        await prefs.setString(_lastPromptDateKey, DateTime.now().toIso8601String());
      },
      onDismissed: () async {
        final count = (prefs.getInt(_dismissCountKey) ?? 0) + 1;
        await prefs.setInt(_dismissCountKey, count);
      },
    ),
  );
}

class _ReviewDialog extends StatefulWidget {
  final Future<void> Function() onReviewDone;
  final Future<void> Function() onPromptShown;
  final Future<void> Function() onDismissed;

  const _ReviewDialog({
    required this.onReviewDone,
    required this.onPromptShown,
    required this.onDismissed,
  });

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

enum _DialogPhase { preQualify, rating, thankYou, feedback }

class _ReviewDialogState extends State<_ReviewDialog> {
  _DialogPhase _phase = _DialogPhase.preQualify;
  int _selectedStars = 0;

  @override
  void initState() {
    super.initState();
    widget.onPromptShown();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedSize(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
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
          child: _buildCurrentPhase(),
        ),
      ),
    );
  }

  Widget _buildCurrentPhase() {
    switch (_phase) {
      case _DialogPhase.preQualify:
        return _buildPreQualify();
      case _DialogPhase.rating:
        return _buildRating();
      case _DialogPhase.thankYou:
        return _buildThankYou();
      case _DialogPhase.feedback:
        return _buildFeedback();
    }
  }

  /// Phase 1: "Are you enjoying Completionist?"
  Widget _buildPreQualify() {
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
          'Your opinion helps other gamers\nfind trophy guides',
          textAlign: TextAlign.center,
          style: TextStyle(color: textSecondary, fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _phase = _DialogPhase.feedback),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryAccentColor.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'NOT REALLY',
                      style: GoogleFonts.inter(
                        color: textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _phase = _DialogPhase.rating),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: accentGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'YES!',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        GestureDetector(
          onTap: _dismiss,
          child: Text(
            'Maybe later',
            style: TextStyle(color: textMuted, fontSize: 13),
          ),
        ),
      ],
    );
  }

  /// Phase 2: Star rating (only shown to users who said "Yes!")
  Widget _buildRating() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Awesome! How many stars?',
          style: GoogleFonts.inter(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Tap a star to rate',
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
              onTap: _selectedStars > 0 ? _onSubmitRating : null,
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
      ],
    );
  }

  /// Phase 3a: Thank you (for 5 stars → redirect to store)
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

  /// Phase 3b: Feedback collection (for users who said "Not really")
  Widget _buildFeedback() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primaryAccentColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.feedback_rounded, size: 40, color: primaryAccentColor),
        ),
        SizedBox(height: 16),
        Text(
          'We\'d love to improve!',
          style: GoogleFonts.inter(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Your feedback helps us build a better\nexperience for gamers like you.',
          textAlign: TextAlign.center,
          style: TextStyle(color: textSecondary, fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: () async {
              await widget.onReviewDone();
              if (mounted) setState(() => _phase = _DialogPhase.thankYou);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: accentGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'SEND FEEDBACK',
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
        SizedBox(height: 12),
        GestureDetector(
          onTap: _dismiss,
          child: Text(
            'No thanks',
            style: TextStyle(color: textMuted, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Future<void> _onSubmitRating() async {
    await widget.onReviewDone();

    if (_selectedStars >= 4) {
      // 4-5 stars → send to app store
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
      // 1-3 stars → collect feedback, don't send to store
      setState(() => _phase = _DialogPhase.thankYou);
    }
  }

  void _dismiss() {
    widget.onDismissed();
    Navigator.pop(context);
  }
}
