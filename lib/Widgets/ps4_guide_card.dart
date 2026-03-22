import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:game_trophy_manager/Model/game_guide_model.dart';
import 'package:game_trophy_manager/Model/game_model.dart';
import 'package:game_trophy_manager/Provider/ps4_guide_provider.dart';
import 'package:game_trophy_manager/Provider/internal_db_provider.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:game_trophy_manager/Widgets/snack_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

// ignore: must_be_immutable
class PS4GuideCard extends StatefulWidget {
  int index;
  GameModel game;
  bool isCompleted;
  bool isStarred;

  PS4GuideCard({
    required this.index,
    required this.game,
    required this.isCompleted,
    required this.isStarred,
  });

  @override
  _PS4GuideCardState createState() => _PS4GuideCardState();
}

class _PS4GuideCardState extends State<PS4GuideCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    double wp = MediaQuery.of(context).size.width;
    final guide =
        Provider.of<PS4GuideProvider>(context).guide[widget.index];
    final tColor = trophyColor(guide.trophyType);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: FocusedMenuHolder(
        menuBoxDecoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        menuWidth: wp * 0.5,
        menuItemExtent: 56,
        blurSize: 4,
        blurBackgroundColor: primaryColor,
        onPressed: () {},
        menuItems: [
          FocusedMenuItem(
            backgroundColor: surfaceColor,
            title: Text(
              widget.isStarred ? 'Un-Star' : 'Star',
              style: GoogleFonts.inter(
                color: widget.isStarred ? neonPink : textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailingIcon: Icon(
              widget.isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
              color: widget.isStarred ? neonPink : goldenColor,
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              GuideModel g =
                  Provider.of<PS4GuideProvider>(context, listen: false)
                      .guide[widget.index];
              g.gameName = widget.game.gameName;
              g.gameImgUrl = widget.game.gameImageUrl;
              if (widget.isStarred) {
                Provider.of<InternalDbProvider>(context, listen: false)
                    .removeTrophyFromStarred(g);
              } else {
                Provider.of<InternalDbProvider>(context, listen: false)
                    .addTrophyToStarred(g);
              }
              setState(() => widget.isStarred = !widget.isStarred);
              snackBar(
                context,
                widget.isStarred ? 'Starred' : 'Un-Starred',
                "${g.trophyName} has been ${widget.isStarred ? 'starred' : 'un-starred'}",
                wp,
              );
            },
          ),
          FocusedMenuItem(
            backgroundColor: surfaceColor,
            title: Text(
              widget.isCompleted ? 'Un-Complete' : 'Complete',
              style: GoogleFonts.inter(
                color: widget.isCompleted ? neonPink : textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailingIcon: Icon(
              widget.isCompleted
                  ? Icons.remove_done_rounded
                  : Icons.check_circle_outline_rounded,
              color: widget.isCompleted ? neonPink : neonGreen,
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              GuideModel g =
                  Provider.of<PS4GuideProvider>(context, listen: false)
                      .guide[widget.index];
              g.gameName = widget.game.gameName;
              g.gameImgUrl = widget.game.gameImageUrl;
              if (widget.isCompleted) {
                Provider.of<InternalDbProvider>(context, listen: false)
                    .removeTrophyFromComplete(g);
              } else {
                Provider.of<InternalDbProvider>(context, listen: false)
                    .addTrophyToComplete(g);
              }
              setState(() => widget.isCompleted = !widget.isCompleted);
              snackBar(
                context,
                widget.isCompleted ? 'Completed' : 'Un-Completed',
                "${g.trophyName} has been ${widget.isCompleted ? 'completed' : 'un-completed'}",
                wp,
              );
            },
          ),
        ],
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isCompleted
                  ? neonGreen.withValues(alpha: 0.2)
                  : (widget.isStarred
                      ? goldenColor.withValues(alpha: 0.2)
                      : tColor.withValues(alpha: 0.08)),
              width: 1,
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              childrenPadding: EdgeInsets.zero,
              onExpansionChanged: (value) {
                setState(() => isExpanded = value);
              },
              leading: Stack(
                children: [
                  Container(
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
                        imageUrl: guide.trophyImage,
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
                  // Status indicators
                  if (widget.isCompleted)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check_circle_rounded,
                            size: 16, color: neonGreen),
                      ),
                    ),
                  if (widget.isStarred && !widget.isCompleted)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.star_rounded,
                            size: 16, color: goldenColor),
                      ),
                    ),
                ],
              ),
              title: Text(
                guide.trophyName,
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
                  guide.trophyDescription,
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
                      Divider(
                        color: tColor.withValues(alpha: 0.1),
                        height: 1,
                      ),
                      SizedBox(height: 12),
                      HtmlWidget(
                        guide.trophyGuide,
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
        ),
      ),
    );
  }
}
