import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:game_trophy_manager/Provider/internal_db_provider.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:game_trophy_manager/Utilities/html_widget_helpers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class MyStarredTrophyPage extends StatefulWidget {
  @override
  _MyStarredTrophyPageState createState() => _MyStarredTrophyPageState();
}

class _MyStarredTrophyPageState extends State<MyStarredTrophyPage> {
  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<InternalDbProvider>(context);
    final hasTrophies = dbProvider.myStarredTrophy.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: hasTrophies
          ? AnimationLimiter(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: dbProvider.myStarredTrophy.length,
                itemBuilder: (BuildContext context, int index) {
                  final trophy = dbProvider.myStarredTrophy[index];
                  final tColor = trophyColor(trophy.trophyType);

                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 30.0,
                      child: FadeInAnimation(
                        child: _TrophyExpansionCard(
                          trophy: trophy,
                          tColor: tColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          : _buildEmptyState(),
    );
  }

  Widget _buildEmptyState() {
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
                color: goldenColor.withValues(alpha: 0.15),
              ),
            ),
            child: Icon(
              Icons.star_outline_rounded,
              size: 48,
              color: textMuted,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'No starred trophies',
            style: GoogleFonts.inter(
              color: textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Star trophies to keep track\nof your goals',
            textAlign: TextAlign.center,
            style: TextStyle(color: textMuted, fontSize: 14, height: 1.5),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).scale(
          begin: Offset(0.9, 0.9), end: Offset(1.0, 1.0), duration: 400.ms),
    );
  }
}

class _TrophyExpansionCard extends StatelessWidget {
  final dynamic trophy;
  final Color tColor;

  const _TrophyExpansionCard({required this.trophy, required this.tColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: tColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: EdgeInsets.zero,
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: cardColor,
              border: Border.all(
                color: tColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: trophy.trophyImage,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: surfaceColor,
                  highlightColor: cardColor,
                  child: Container(color: surfaceColor),
                ),
                errorWidget: (context, url, error) =>
                    Icon(Icons.error_outline, color: textMuted, size: 20),
              ),
            ),
          ),
          title: Text(
            trophy.trophyName,
            style: GoogleFonts.inter(
              color: textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              trophy.trophyDescription,
              style: TextStyle(color: textSecondary, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: tColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              size: 20,
              color: tColor,
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: tColor.withValues(alpha: 0.1), height: 1),
                  SizedBox(height: 12),
                  HtmlWidget(
                    trophy.trophyGuide,
                    customWidgetBuilder: buildHtmlVideoWidget,
                    onTapUrl: (url) async => await launchHtmlUrl(url),
                    textStyle: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
