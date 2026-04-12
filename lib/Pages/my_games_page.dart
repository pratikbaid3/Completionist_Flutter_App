import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:game_trophy_manager/Model/merged_game_model.dart';
import 'package:game_trophy_manager/Provider/internal_db_provider.dart';
import 'package:game_trophy_manager/Provider/ps4_guide_provider.dart';
import 'package:game_trophy_manager/Provider/psn_sync_provider.dart';
import 'package:game_trophy_manager/Router/router_constant.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class MyGamesPage extends StatefulWidget {
  @override
  _MyGamesPageState createState() => _MyGamesPageState();
}

class _MyGamesPageState extends State<MyGamesPage> {
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

    return KeyboardDismissOnTap(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: hasGames
            ? AnimationLimiter(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: mergedGames.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = mergedGames[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 30.0,
                        child: FadeInAnimation(
                          child: _MergedGameTile(item: item),
                        ),
                      ),
                    );
                  },
                ),
              )
            : _buildEmptyState(psnProvider.isConnected),
      ),
    );
  }

  Widget _buildEmptyState(bool isConnected) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: surfaceColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryAccentColor.withValues(alpha: 0.15),
              ),
            ),
            child: Icon(
              Icons.gamepad_outlined,
              size: 48,
              color: textMuted,
            ),
          ),
          SizedBox(height: 20),
          Text(
            isConnected ? 'No synced games yet' : 'No games yet',
            style: GoogleFonts.inter(
              color: textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            isConnected
                ? 'Try refreshing PSN from the dashboard or browse games manually.'
                : 'Browse games or connect PSN to build your library.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textMuted,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).scale(
            begin: Offset(0.9, 0.9),
            end: Offset(1.0, 1.0),
            duration: 400.ms,
          ),
    );
  }
}

class _MergedGameTile extends StatelessWidget {
  final MergedGameModel item;

  const _MergedGameTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final game = item.toGameModel();
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Provider.of<PS4GuideProvider>(context, listen: false)
                .clearGuideList();
            Navigator.of(context).pushNamed(
              guidePageRoute,
              arguments: {
                'game': game,
                'guideEndpoint': game.guideEndpoint,
              },
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: primaryAccentColor.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: cardColor,
                      border: Border.all(
                        color: primaryAccentColor.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: surfaceColor,
                          highlightColor: cardColor,
                          child: Container(color: surfaceColor),
                        ),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.error_outline, color: textMuted),
                      ),
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _Tag(
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
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _TrophyBadge(
                              count: item.totalGold,
                              color: goldenColor,
                            ),
                            _TrophyBadge(
                              count: item.totalSilver,
                              color: silverColor,
                            ),
                            _TrophyBadge(
                              count: item.totalBronze,
                              color: bronzeColor,
                            ),
                            _TrophyBadge(
                              count: item.totalPlatinum,
                              color: platinumColor,
                            ),
                          ],
                        ),
                        if (item.localCompletedCount > 0 ||
                            item.localStarredCount > 0) ...[
                          SizedBox(height: 8),
                          Text(
                            'Tracked trophies: ${item.localCompletedCount} completed • ${item.localStarredCount} starred',
                            style: TextStyle(color: textMuted, fontSize: 11),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryAccentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: primaryAccentColor,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.16)),
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

class _TrophyBadge extends StatelessWidget {
  final int count;
  final Color color;

  const _TrophyBadge({
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded, color: color, size: 14),
          SizedBox(width: 4),
          Text(
            '$count',
            style: GoogleFonts.inter(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
