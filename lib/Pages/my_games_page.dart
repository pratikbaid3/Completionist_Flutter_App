import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:game_trophy_manager/Provider/ps4_guide_provider.dart';
import 'package:game_trophy_manager/Provider/internal_db_provider.dart';
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
    final hasGames = dbProvider.myGames.isNotEmpty;

    return KeyboardDismissOnTap(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: hasGames
            ? AnimationLimiter(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: dbProvider.myGames.length,
                  itemBuilder: (BuildContext context, int index) {
                    final game = dbProvider.myGames[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 30.0,
                        child: FadeInAnimation(
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 6),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {
                                  Provider.of<PS4GuideProvider>(context,
                                          listen: false)
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
                                      color: primaryAccentColor
                                          .withValues(alpha: 0.08),
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
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: cardColor,
                                            border: Border.all(
                                              color: primaryAccentColor
                                                  .withValues(alpha: 0.15),
                                              width: 1,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: CachedNetworkImage(
                                              imageUrl: game.gameImageUrl,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Shimmer.fromColors(
                                                baseColor: surfaceColor,
                                                highlightColor: cardColor,
                                                child: Container(
                                                    color: surfaceColor),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(
                                                Icons.error_outline,
                                                color: textMuted,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                game.gameName,
                                                style: GoogleFonts.inter(
                                                  color: textPrimary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                ),
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  _TrophyBadge(
                                                      count: game.gold,
                                                      color: goldenColor),
                                                  SizedBox(width: 8),
                                                  _TrophyBadge(
                                                      count: game.silver,
                                                      color: silverColor),
                                                  SizedBox(width: 8),
                                                  _TrophyBadge(
                                                      count: game.bronze,
                                                      color: bronzeColor),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: primaryAccentColor
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons
                                                .arrow_forward_ios_rounded,
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
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            : Center(
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
                      'No games yet',
                      style: GoogleFonts.inter(
                        color: textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Browse games and add them\nto your library',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scale(
                      begin: Offset(0.9, 0.9),
                      end: Offset(1.0, 1.0),
                      duration: 400.ms,
                    ),
              ),
      ),
    );
  }
}

class _TrophyBadge extends StatelessWidget {
  final String count;
  final Color color;
  const _TrophyBadge({required this.count, required this.color});

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
            count,
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
