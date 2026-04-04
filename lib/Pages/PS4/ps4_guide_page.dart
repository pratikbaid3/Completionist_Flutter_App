import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:game_trophy_manager/Model/Enum/game_guide_filter_enum.dart';
import 'package:game_trophy_manager/Model/game_guide_model.dart';
import 'package:game_trophy_manager/Model/game_model.dart';
import 'package:game_trophy_manager/Provider/ps4_guide_provider.dart';
import 'package:game_trophy_manager/Provider/internal_db_provider.dart';
import 'package:game_trophy_manager/Utilities/analytics.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:game_trophy_manager/Widgets/aurora_background.dart';
import 'package:game_trophy_manager/Widgets/ps4_guide_card.dart';
import 'package:game_trophy_manager/Widgets/review_dialog.dart';
import 'package:game_trophy_manager/Widgets/snack_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

// ignore: must_be_immutable
class Ps4GuidePage extends StatefulWidget {
  GameModel game;
  final String guideEndpoint;
  Ps4GuidePage({required this.game, this.guideEndpoint = 'ps4/guide/'});

  @override
  _Ps4GuidePageState createState() => _Ps4GuidePageState();
}

class _Ps4GuidePageState extends State<Ps4GuidePage> {
  bool isGameAdded = false;
  GameGuideFilterEnum filter = GameGuideFilterEnum.All;

  @override
  void initState() {
    super.initState();
    Analytics.logScreenView('game_detail');
    Analytics.logViewGame(
      widget.game.gameName,
      widget.guideEndpoint.contains('ps5') ? 'PS5' : 'PS4',
    );
    initializeGameState();
  }

  Future initializeGameState() async {
    List<GameModel> myGames =
        Provider.of<InternalDbProvider>(context, listen: false).myGames;
    for (GameModel g in myGames) {
      if (g.gameName == widget.game.gameName) {
        setState(() => isGameAdded = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double wp = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: primaryColor,
      body: AuroraBackground(
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(wp),
            SliverToBoxAdapter(child: _buildFilterRow()),
            _buildTrophyList(wp),
            SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(double wp) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: primaryColor,
      surfaceTintColor: Colors.transparent,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: primaryAccentColor.withValues(alpha: 0.2)),
          ),
          child: Icon(Icons.arrow_back_rounded, color: textPrimary, size: 20),
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: primaryAccentColor.withValues(alpha: 0.2)),
          ),
          child: PopupMenuButton<String>(
            color: surfaceColor,
            icon: Icon(Icons.more_vert_rounded, color: textPrimary, size: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: primaryAccentColor.withValues(alpha: 0.15)),
            ),
            onSelected: (value) {
              HapticFeedback.mediumImpact();
              if (value == 'Add Game') {
                widget.game.guideEndpoint = widget.guideEndpoint;
                final dbProvider = Provider.of<InternalDbProvider>(context, listen: false);
                dbProvider.addGameToDb(widget.game, context);
                setState(() => isGameAdded = true);
                Analytics.logAddGame(widget.game.gameName);
                snackBar(context, 'Added', "${widget.game.gameName} has been added", wp);
                maybeShowReview(
                  context,
                  ReviewTrigger.gameMilestone,
                  totalGames: dbProvider.myGames.length,
                );
              }
              if (value == 'Remove Game') {
                Provider.of<InternalDbProvider>(context, listen: false)
                    .removeGameFromDb(widget.game, context);
                setState(() => isGameAdded = false);
                Analytics.logRemoveGame(widget.game.gameName);
                snackBar(context, 'Removed', "${widget.game.gameName} has been removed", wp);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: isGameAdded ? 'Remove Game' : 'Add Game',
                  child: Row(
                    children: [
                      Icon(
                        isGameAdded ? Icons.remove_circle_outline_rounded : Icons.add_circle_outline_rounded,
                        color: isGameAdded ? neonPink : neonGreen,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        isGameAdded ? 'Remove Game' : 'Add Game',
                        style: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: widget.game.gameImageUrl,
              fit: BoxFit.cover,
              placeholder: (ctx, url) => Shimmer.fromColors(
                baseColor: surfaceColor,
                highlightColor: cardColor,
                child: Container(color: surfaceColor),
              ),
              errorWidget: (ctx, url, err) => Container(
                color: surfaceColor,
                child: Icon(Icons.image_not_supported_rounded, color: textMuted, size: 40),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primaryColor.withValues(alpha: 0.3),
                    primaryColor.withValues(alpha: 0.0),
                    primaryColor.withValues(alpha: 0.8),
                    primaryColor,
                  ],
                  stops: [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.game.gameName,
                    style: GoogleFonts.orbitron(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 1),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      _TrophyChip(count: widget.game.gold, color: goldenColor),
                      SizedBox(width: 8),
                      _TrophyChip(count: widget.game.silver, color: silverColor),
                      SizedBox(width: 8),
                      _TrophyChip(count: widget.game.bronze, color: bronzeColor),
                      Spacer(),
                      if (isGameAdded)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: neonGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: neonGreen.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_rounded, size: 14, color: neonGreen),
                              SizedBox(width: 4),
                              Text('In Library', style: TextStyle(color: neonGreen, fontSize: 11)),
                            ],
                          ),
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
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text('TROPHIES', style: GoogleFonts.orbitron(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2)),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: primaryAccentColor.withValues(alpha: 0.15)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<GameGuideFilterEnum>(
                dropdownColor: surfaceColor,
                value: filter,
                style: GoogleFonts.inter(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                iconEnabledColor: primaryAccentColor,
                iconSize: 20,
                borderRadius: BorderRadius.circular(12),
                items: GameGuideFilterEnum.values.map((filterType) {
                  return DropdownMenuItem<GameGuideFilterEnum>(
                    value: filterType,
                    child: Text(filterType.toString().split('.')[1]),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    HapticFeedback.selectionClick();
                    Analytics.logFilter(value.toString().split('.')[1], widget.game.gameName);
                    setState(() => filter = value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrophyList(double wp) {
    return SliverToBoxAdapter(
      child: FutureBuilder(
        future: Provider.of<PS4GuideProvider>(context).getGuide(gameName: widget.game.gameName, endpoint: widget.guideEndpoint),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (Provider.of<PS4GuideProvider>(context).guide.isEmpty) {
            return Container(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 40, height: 40, child: CircularProgressIndicator(color: primaryAccentColor, strokeWidth: 2)),
                    SizedBox(height: 16),
                    Text('Loading trophies...', style: TextStyle(color: textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            );
          }
          return AnimationLimiter(
            child: ListView.builder(
              primary: false,
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              itemCount: Provider.of<PS4GuideProvider>(context).guide.length,
              itemBuilder: (BuildContext context, int index) {
                bool isCompleted = false;
                bool isStarred = false;
                String trophyName = Provider.of<PS4GuideProvider>(context).guide[index].trophyName;

                for (GuideModel guide in Provider.of<InternalDbProvider>(context).myCompletedTrophy) {
                  if (guide.trophyName == trophyName) isCompleted = true;
                }
                for (GuideModel guide in Provider.of<InternalDbProvider>(context).myStarredTrophy) {
                  if (guide.trophyName == trophyName) isStarred = true;
                }

                if (filter == GameGuideFilterEnum.Completed && !isCompleted) return SizedBox.shrink();
                if (filter == GameGuideFilterEnum.Incomplete && isCompleted) return SizedBox.shrink();

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: Duration(milliseconds: 350),
                  child: SlideAnimation(
                    verticalOffset: 25.0,
                    child: FadeInAnimation(
                      child: PS4GuideCard(index: index, game: widget.game, isStarred: isStarred, isCompleted: isCompleted),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _TrophyChip extends StatelessWidget {
  final String count;
  final Color color;
  const _TrophyChip({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded, size: 12, color: color),
          SizedBox(width: 4),
          Text(count, style: GoogleFonts.inter(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
