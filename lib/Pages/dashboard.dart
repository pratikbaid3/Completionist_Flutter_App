import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_trophy_manager/Provider/ps4_guide_provider.dart';
import 'package:game_trophy_manager/Provider/internal_db_provider.dart';
import 'package:game_trophy_manager/Router/router_constant.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:game_trophy_manager/Widgets/ps4_guide_card_dashboard.dart';
import 'package:game_trophy_manager/Widgets/review_dialog.dart';

import 'package:game_trophy_manager/Utilities/analytics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isExpanded = false;
  static bool _reviewChecked = false;

  @override
  void initState() {
    super.initState();
    if (!_reviewChecked) {
      _reviewChecked = true;
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) maybeShowReview(context, ReviewTrigger.appOpenFallback);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double wp = MediaQuery.of(context).size.width;
    final dbProvider = Provider.of<InternalDbProvider>(context);
    final hasGames = dbProvider.myGames.isNotEmpty;
    final hasCompleted = dbProvider.myCompletedTrophy.isNotEmpty;
    final hasStarred = dbProvider.myStarredTrophy.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            _buildGameCarousel(context, dbProvider, hasGames, wp),
            if (hasGames) _buildQuickStats(dbProvider, wp),
            _buildSectionHeader('Recently', 'Completed',
                Icons.check_circle_rounded, neonGreen, wp),
            hasCompleted
                ? _buildCompletedList(dbProvider, wp)
                : _buildEmptyState(
                    'No completed trophies yet',
                    'Long press any trophy to mark as completed',
                    Icons.emoji_events_outlined,
                  ),
            _buildSectionHeader(
                'Recently', 'Starred', Icons.star_rounded, goldenColor, wp),
            hasStarred
                ? _buildStarredList(dbProvider, wp)
                : _buildEmptyState(
                    'No starred trophies yet',
                    'Star trophies to track your goals',
                    Icons.star_outline_rounded,
                  ),
            SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCarousel(BuildContext context, InternalDbProvider dbProvider,
      bool hasGames, double wp) {
    if (hasGames) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryAccentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.gamepad_rounded, size: 16, color: primaryAccentColor),
                ),
                SizedBox(width: 10),
                Text(
                  'My',
                  style: GoogleFonts.inter(
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: wp * 0.045,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  'Library',
                  style: GoogleFonts.inter(
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: wp * 0.045,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: dbProvider.myGames.length,
              itemBuilder: (context, index) {
                final game = dbProvider.myGames[index];
                return GestureDetector(
                  onTap: () {
                    Provider.of<PS4GuideProvider>(context, listen: false)
                        .clearGuideList();
                    Navigator.of(context)
                        .pushNamed(guidePageRoute, arguments: game);
                  },
                  child: Container(
                    width: 150,
                    margin: EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: primaryAccentColor.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Game image
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: CachedNetworkImage(
                                imageUrl: game.gameImageUrl,
                                fit: BoxFit.contain,
                                placeholder: (ctx, url) => Shimmer.fromColors(
                                  baseColor: surfaceColor,
                                  highlightColor: cardColor,
                                  child: Container(color: surfaceColor),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Game name + trophy counts
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                game.gameName,
                                style: GoogleFonts.inter(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 6),
                              Row(
                                children: [
                                  _MiniTrophy(count: game.gold, color: goldenColor),
                                  SizedBox(width: 6),
                                  _MiniTrophy(count: game.silver, color: silverColor),
                                  SizedBox(width: 6),
                                  _MiniTrophy(count: game.bronze, color: bronzeColor),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      )
          .animate()
          .fadeIn(duration: 600.ms)
          .slideY(begin: 0.1, end: 0, duration: 600.ms);
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: EdgeInsets.all(32),
      decoration: neonCardDecoration(glowColor: primaryAccentColor),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'images/app_icon.png',
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Start Your Journey',
            style: GoogleFonts.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Browse games and add them to your library to track your trophy progress',
            textAlign: TextAlign.center,
            style: TextStyle(color: textSecondary, fontSize: 14, height: 1.5),
          ),
          SizedBox(height: 24),
          _GlowButton(
            onPressed: () {
              Analytics.logBrowseGames();
              Navigator.of(context).pushNamed(ps4GamePageRoute);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FontAwesomeIcons.playstation, size: 18),
                SizedBox(width: 12),
                Text(
                  'BROWSE GAMES',
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2, end: 0, duration: 600.ms);
  }

  Widget _buildQuickStats(InternalDbProvider dbProvider, double wp) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: glassDecoration(borderRadius: 14, opacity: 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatChip(
              icon: Icons.gamepad_rounded,
              value: '${dbProvider.myGames.length}',
              label: 'Games',
              color: primaryAccentColor),
          _divider(),
          _StatChip(
              icon: Icons.check_circle_rounded,
              value: '${dbProvider.myCompletedTrophy.length}',
              label: 'Done',
              color: neonGreen),
          _divider(),
          _StatChip(
              icon: Icons.star_rounded,
              value: '${dbProvider.myStarredTrophy.length}',
              label: 'Starred',
              color: goldenColor),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _divider() {
    return Container(
        width: 1, height: 30, color: textMuted.withValues(alpha: 0.3));
  }

  Widget _buildSectionHeader(
      String text1, String text2, IconData icon, Color color, double wp) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: color),
          ),
          SizedBox(width: 10),
          Text(text1,
              style: GoogleFonts.inter(
                  color: textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: wp * 0.045)),
          SizedBox(width: 4),
          Text(text2,
              style: GoogleFonts.inter(
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: wp * 0.045)),
        ],
      ),
    );
  }

  Widget _buildCompletedList(InternalDbProvider dbProvider, double wp) {
    final count = dbProvider.myCompletedTrophy.length > 5
        ? 5
        : dbProvider.myCompletedTrophy.length;
    return AnimationLimiter(
      child: ListView.builder(
        primary: false,
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: wp * 0.04, vertical: 4),
        itemCount: count,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: Duration(milliseconds: 375),
            child: SlideAnimation(
                verticalOffset: 30.0,
                child: FadeInAnimation(
                  child: PS4GuideCardDashboard(
                      isExpanded: isExpanded,
                      index: index,
                      onExpanded: (value) {
                        setState(() => isExpanded = value);
                      }),
                )),
          );
        },
      ),
    );
  }

  Widget _buildStarredList(InternalDbProvider dbProvider, double wp) {
    final count = dbProvider.myStarredTrophy.length > 5
        ? 5
        : dbProvider.myStarredTrophy.length;
    return AnimationLimiter(
      child: ListView.builder(
        primary: false,
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: wp * 0.04, vertical: 4),
        itemCount: count,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: Duration(milliseconds: 375),
            child: SlideAnimation(
                verticalOffset: 30.0,
                child: FadeInAnimation(
                  child: PS4GuideCardDashboard(
                      isExpanded: isExpanded,
                      index: index,
                      onExpanded: (value) {
                        setState(() => isExpanded = value);
                      },
                      isStarred: true),
                )),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: glassDecoration(borderRadius: 16, opacity: 0.03),
      child: Column(
        children: [
          Icon(icon, size: 40, color: textMuted),
          SizedBox(height: 12),
          Text(title,
              style: GoogleFonts.inter(
                  color: textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15)),
          SizedBox(height: 4),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: textMuted, fontSize: 13)),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatChip(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        SizedBox(height: 6),
        Text(value,
            style: GoogleFonts.orbitron(
                fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary)),
        SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: textSecondary)),
      ],
    );
  }
}

class _GlowButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  const _GlowButton({required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: accentGradient,
        boxShadow: [
          BoxShadow(
              color: primaryAccentColor.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: DefaultTextStyle(
              style: TextStyle(color: Colors.white),
              child: IconTheme(
                  data: IconThemeData(color: Colors.white), child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniTrophy extends StatelessWidget {
  final String count;
  final Color color;
  const _MiniTrophy({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.emoji_events_rounded, size: 12, color: color),
        SizedBox(width: 2),
        Text(
          count,
          style: GoogleFonts.inter(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
