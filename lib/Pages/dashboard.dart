import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_trophy_manager/Model/merged_game_model.dart';
import 'package:game_trophy_manager/Pages/psn_login_page.dart';
import 'package:game_trophy_manager/Provider/internal_db_provider.dart';
import 'package:game_trophy_manager/Provider/ps4_guide_provider.dart';
import 'package:game_trophy_manager/Provider/psn_sync_provider.dart';
import 'package:game_trophy_manager/Router/router_constant.dart';
import 'package:game_trophy_manager/Utilities/analytics.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:game_trophy_manager/Widgets/ps4_guide_card_dashboard.dart';
import 'package:game_trophy_manager/Widgets/review_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
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
    final dbProvider = Provider.of<InternalDbProvider>(context);
    final psnProvider = Provider.of<PsnSyncProvider>(context);
    final mergedGames = psnProvider.mergeGames(
      dbProvider.myGames,
      dbProvider.myPsnGames,
      dbProvider.myCompletedTrophy,
      dbProvider.myStarredTrophy,
    );
    final hasGames = mergedGames.isNotEmpty;
    final wp = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            if (!(psnProvider.isConnected && psnProvider.profile != null))
              _buildPsnCard(context, psnProvider, dbProvider, wp),
            _buildGameCarousel(context, mergedGames, hasGames, wp),
            if (hasGames)
              _buildQuickStats(
                mergedGames: mergedGames,
                dbProvider: dbProvider,
                psnProvider: psnProvider,
              ),
            _buildSectionHeader(
              'Recently Completed',
              Icons.check_circle_rounded,
              neonGreen,
            ),
            dbProvider.myCompletedTrophy.isNotEmpty
                ? _buildGuideList(dbProvider.myCompletedTrophy.length, false)
                : _buildEmptyState(
                    'No completed trophies yet',
                    'Long press any trophy to mark it as completed.',
                    Icons.emoji_events_outlined,
                  ),
            _buildSectionHeader(
              'Recently Starred',
              Icons.star_rounded,
              goldenColor,
            ),
            dbProvider.myStarredTrophy.isNotEmpty
                ? _buildGuideList(dbProvider.myStarredTrophy.length, true)
                : _buildEmptyState(
                    'No starred trophies yet',
                    'Star trophies to keep your next targets front and center.',
                    Icons.star_outline_rounded,
                  ),
            SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildPsnCard(
    BuildContext context,
    PsnSyncProvider psnProvider,
    InternalDbProvider dbProvider,
    double wp,
  ) {
    final isConnected = psnProvider.isConnected && psnProvider.profile != null;
    final statusLabel = psnProvider.isBusy
        ? 'Syncing'
        : isConnected
            ? 'Connected'
            : 'Optional';
    final statusColor = psnProvider.isBusy
        ? secondaryAccentColor
        : isConnected
            ? neonGreen
            : textMuted;
    final titleStyle = GoogleFonts.orbitron(
      color: textPrimary,
      fontWeight: FontWeight.w700,
      fontSize: wp * 0.034,
      letterSpacing: 0.8,
    );
    final summaryText = isConnected
        ? '${dbProvider.myPsnGames.length} titles • ${psnProvider.lastSyncLabel()}'
        : 'Sync your PSN games';

    return Container(
      margin: EdgeInsets.fromLTRB(20, 4, 20, 16),
      padding: EdgeInsets.all(12),
      decoration: neonCardDecoration(glowColor: primaryAccentColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryAccentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  FontAwesomeIcons.playstation,
                  color: primaryAccentColor,
                  size: 14,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PSN Sync', style: titleStyle),
                    SizedBox(height: 2),
                    Text(
                      summaryText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 11,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showPsnInfoSheet(context, isConnected),
                icon: Icon(
                  Icons.info_outline_rounded,
                  color: textMuted,
                  size: 18,
                ),
                splashRadius: 18,
                constraints: BoxConstraints.tightFor(width: 32, height: 32),
                padding: EdgeInsets.zero,
              ),
              _StatusPill(
                label: statusLabel,
                color: statusColor,
              ),
            ],
          ),
          if (psnProvider.syncError.isNotEmpty) ...[
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: neonPink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: neonPink.withValues(alpha: 0.16)),
              ),
              child: Text(
                psnProvider.syncError,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(color: textPrimary, fontSize: 11, height: 1.35),
              ),
            ),
          ],
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _PsnActionButton(
                  isConnectMode: !isConnected,
                  onPressed: psnProvider.isBusy
                      ? null
                      : () {
                          if (isConnected) {
                            psnProvider.syncNow(dbProvider, force: true);
                          } else {
                            _startPsnLogin(context, psnProvider, dbProvider);
                          }
                        },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isConnected
                            ? Icons.refresh_rounded
                            : Icons.link_rounded,
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        isConnected ? 'REFRESH' : 'CONNECT',
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isConnected) ...[
                SizedBox(width: 6),
                IconButton(
                  onPressed: psnProvider.isBusy
                      ? null
                      : () => psnProvider.disconnect(dbProvider),
                  icon: Icon(
                    Icons.link_off_rounded,
                    size: 18,
                    color: textMuted,
                  ),
                  constraints: BoxConstraints.tightFor(width: 34, height: 34),
                  splashRadius: 18,
                  padding: EdgeInsets.zero,
                  tooltip: 'Disconnect',
                ),
              ],
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.08, end: 0, duration: 400.ms);
  }

  Widget _buildGameCarousel(
    BuildContext context,
    List<MergedGameModel> games,
    bool hasGames,
    double wp,
  ) {
    if (!hasGames) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: EdgeInsets.all(32),
        decoration: glassDecoration(borderRadius: 18, opacity: 0.06),
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
              'Connect PSN or browse games manually to build your dashboard.',
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
          .fadeIn(duration: 500.ms)
          .slideY(begin: 0.12, end: 0, duration: 500.ms);
    }

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
                child: Icon(Icons.gamepad_rounded,
                    size: 16, color: primaryAccentColor),
              ),
              SizedBox(width: 10),
              Text(
                'My Library',
                style: GoogleFonts.inter(
                  color: textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: wp * 0.046,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final item = games[index];
              final game = item.toGameModel();
              return GestureDetector(
                onTap: () {
                  Provider.of<PS4GuideProvider>(context, listen: false)
                      .clearGuideList();
                  Navigator.of(context).pushNamed(
                    guidePageRoute,
                    arguments: {
                      'game': game,
                      'guideEndpoint': game.guideEndpoint
                    },
                  );
                },
                child: Container(
                  width: 168,
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
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16)),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: CachedNetworkImage(
                                    imageUrl: item.imageUrl,
                                    fit: BoxFit.contain,
                                    placeholder: (ctx, url) =>
                                        Shimmer.fromColors(
                                      baseColor: surfaceColor,
                                      highlightColor: cardColor,
                                      child: Container(color: surfaceColor),
                                    ),
                                    errorWidget: (_, __, ___) => Icon(
                                      Icons.hide_image_outlined,
                                      color: textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 8, 10, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _StatusPill(
                                  label: item.platform.toUpperCase(),
                                  color: item.platform == 'ps5'
                                      ? secondaryAccentColor
                                      : primaryAccentColor,
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              item.gameName,
                              style: GoogleFonts.inter(
                                color: textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                _MiniTrophy(
                                  count: game.gold,
                                  color: goldenColor,
                                ),
                                SizedBox(width: 6),
                                _MiniTrophy(
                                  count: game.silver,
                                  color: silverColor,
                                ),
                                SizedBox(width: 6),
                                _MiniTrophy(
                                  count: game.bronze,
                                  color: bronzeColor,
                                ),
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

  Widget _buildQuickStats({
    required List<MergedGameModel> mergedGames,
    required InternalDbProvider dbProvider,
    required PsnSyncProvider psnProvider,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: glassDecoration(borderRadius: 14, opacity: 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatChip(
            icon: Icons.gamepad_rounded,
            value: '${mergedGames.length}',
            label: 'All',
            color: primaryAccentColor,
          ),
          _divider(),
          _StatChip(
            icon: FontAwesomeIcons.playstation,
            value: '${dbProvider.myPsnGames.length}',
            label: 'PSN Sync',
            color: goldenColor,
          ),
          _divider(),
          _StatChip(
            icon: Icons.check_circle_rounded,
            value: '${dbProvider.myCompletedTrophy.length}',
            label: 'Done',
            color: neonGreen,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 180.ms, duration: 400.ms);
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 30,
      color: textMuted.withValues(alpha: 0.3),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.inter(
              color: textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideList(int count, bool isStarred) {
    final itemCount = count > 5 ? 5 : count;
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: itemCount,
      itemBuilder: (_, index) => PS4GuideCardDashboard(
        isExpanded: false,
        index: index,
        isStarred: isStarred,
        onExpanded: (_) {},
      ),
    );
  }

  Widget _buildEmptyState(String title, String description, IconData icon) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: glassDecoration(borderRadius: 16, opacity: 0.04),
      child: Column(
        children: [
          Icon(icon, color: textMuted, size: 34),
          SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              color: textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(color: textSecondary, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Future<void> _startPsnLogin(
    BuildContext context,
    PsnSyncProvider psnProvider,
    InternalDbProvider dbProvider,
  ) async {
    final token = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const PsnLoginPage()),
    );
    if (!mounted || token == null || token.isEmpty) return;
    await psnProvider.connectWithNpsso(token, dbProvider);
  }

  Future<void> _showPsnInfoSheet(BuildContext context, bool isConnected) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 14, 20, 24),
                decoration: BoxDecoration(
                  color: secondaryColor.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: textMuted.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryAccentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            FontAwesomeIcons.playstation,
                            color: primaryAccentColor,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'PSN Sync',
                            style: GoogleFonts.orbitron(
                              color: textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      isConnected
                          ? 'Refresh your PlayStation library here any time. Completionist keeps the PSN session and synced data only on this device.'
                          : 'Connect your PlayStation account to import owned games and completed trophies into Completionist.',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                        height: 1.55,
                      ),
                    ),
                    SizedBox(height: 16),
                    _InfoRow(
                      icon: Icons.lock_outline_rounded,
                      title: 'Private by default',
                      description:
                          'Your PSN session and synced library stay on this device.',
                    ),
                    SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Matches your guides',
                      description:
                          'Completionist tries to map synced titles back to your existing catalog and guide data.',
                    ),
                    SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.refresh_rounded,
                      title: 'Refresh on demand',
                      description:
                          'You can refresh manually at any time, and the app can refresh stale data when reopened.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlowButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const _GlowButton({required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryAccentColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: primaryAccentColor.withValues(alpha: 0.4),
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: child,
    );
  }
}

class _PsnActionButton extends StatelessWidget {
  final bool isConnectMode;
  final VoidCallback? onPressed;
  final Widget child;

  const _PsnActionButton({
    required this.isConnectMode,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isConnectMode ? primaryAccentColor : textPrimary;
    final backgroundColor = isConnectMode
        ? primaryAccentColor.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.05);
    final borderColor = isConnectMode
        ? primaryAccentColor.withValues(alpha: 0.3)
        : Colors.white.withValues(alpha: 0.16);

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: activeColor,
        backgroundColor: backgroundColor,
        disabledForegroundColor: textMuted,
        disabledBackgroundColor: backgroundColor.withValues(alpha: 0.45),
        side: BorderSide(
          color: onPressed == null
              ? borderColor.withValues(alpha: 0.45)
              : borderColor,
          width: 1,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        minimumSize: Size(0, 38),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      child: child,
    );
  }
}

class _MiniTrophy extends StatelessWidget {
  final String count;
  final Color color;

  const _MiniTrophy({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded, size: 12, color: color),
          SizedBox(width: 3),
          Text(
            count,
            style: GoogleFonts.inter(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
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

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.orbitron(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: textMuted, fontSize: 11),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: textPrimary),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
