import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:game_trophy_manager/Model/game_guide_model.dart';
import 'package:game_trophy_manager/Provider/internal_db_provider.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class PS4GuideCardDashboard extends StatelessWidget {
  const PS4GuideCardDashboard({
    Key? key,
    required this.isExpanded,
    required this.index,
    required this.onExpanded,
    this.isStarred = false,
  }) : super(key: key);

  final bool isExpanded;
  final int index;
  final void Function(bool) onExpanded;
  final bool isStarred;

  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<InternalDbProvider>(context);
    final List<GuideModel> trophies =
        isStarred ? dbProvider.myStarredTrophy : dbProvider.myCompletedTrophy;

    if (index >= trophies.length) return SizedBox.shrink();

    final trophy = trophies[index];
    final tColor = trophyColor(trophy.trophyType);

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
          onExpansionChanged: onExpanded,
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
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: tColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  size: 20,
                  color: tColor,
                ),
              ),
            ],
          ),
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    color: tColor.withValues(alpha: 0.1),
                    height: 1,
                  ),
                  SizedBox(height: 12),
                  HtmlWidget(
                    trophy.trophyGuide,
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
