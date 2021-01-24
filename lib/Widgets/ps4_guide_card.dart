import 'package:cached_network_image/cached_network_image.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:game_trophy_manager/Model/game_guide_model.dart';
import 'package:game_trophy_manager/Model/game_model.dart';
import 'package:game_trophy_manager/Provider/guide_provider.dart';
import 'package:game_trophy_manager/Provider/internal_db_provider.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:game_trophy_manager/Widgets/snack_bar.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

class PS4GuideCard extends StatefulWidget {
  int index;
  GameModel game;
  bool isCompleted;
  bool isStarred;
  PS4GuideCard(
      {@required this.index,
      @required this.game,
      @required this.isCompleted,
      @required this.isStarred});

  @override
  _PS4GuideCardState createState() => _PS4GuideCardState();
}

class _PS4GuideCardState extends State<PS4GuideCard> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    double hp = MediaQuery.of(context).size.height;
    double wp = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: ExpansionTileCard(
          initialElevation: 0,
          elevation: 0,
          baseColor: secondaryColor,
          expandedColor: secondaryColor,
          onExpansionChanged: (value) {
            setState(() {
              isExpanded = value;
            });
          },
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                LineAwesomeIcons.trophy,
                size: 30,
                color: (Provider.of<GuideProvider>(context)
                            .guide[widget.index]
                            .trophyType ==
                        'BRONZE')
                    ? bronzeColor
                    : ((Provider.of<GuideProvider>(context)
                                .guide[widget.index]
                                .trophyType ==
                            'SILVER')
                        ? silverColor
                        : goldenColor),
              ),
              (!isExpanded)
                  ? Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                    )
                  : Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: Colors.white,
                    ),
            ],
          ),
          title: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 13.0),
            leading: Container(
                padding: EdgeInsets.only(right: 12.0),
                decoration: new BoxDecoration(
                    border: new Border(
                        right:
                            new BorderSide(width: 1.0, color: Colors.white24))),
                child: CachedNetworkImage(
                  imageUrl: Provider.of<GuideProvider>(context)
                      .guide[widget.index]
                      .trophyImage,
                  placeholder: (context, url) => new CircularProgressIndicator(
                    backgroundColor: primaryAccentColor,
                  ),
                  errorWidget: (context, url, error) => new Icon(Icons.error),
                )),
            title: Text(
              '${Provider.of<GuideProvider>(context).guide[widget.index].trophyName}',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Provider.of<GuideProvider>(context, listen: false)
                        .guide[widget.index]
                        .trophyDescription,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ),
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0),
              ),
              child: HtmlWidget(
                '''${Provider.of<GuideProvider>(context, listen: false).guide[widget.index].trophyGuide}''',
                textStyle: TextStyle(fontSize: 15),
                webView: true,
              ),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            )
          ],
        ),
        actions: <Widget>[
          (!widget.isCompleted)
              ? IconSlideAction(
                  caption: 'Complete',
                  color: primaryAccentColor,
                  icon: Icons.check,
                  onTap: () {
                    GuideModel guide =
                        Provider.of<GuideProvider>(context, listen: false)
                            .guide[widget.index];
                    guide.gameName = widget.game.gameName;
                    guide.gameImgUrl = widget.game.gameImageUrl;
                    Provider.of<InternalDbProvider>(context, listen: false)
                        .addTrophyToComplete(guide);
                    setState(() {
                      widget.isCompleted = true;
                    });
                    snackBar(
                        context,
                        'Completed',
                        "${Provider.of<GuideProvider>(context, listen: false).guide[widget.index].trophyName} has been completed",
                        wp);
                  },
                )
              : IconSlideAction(
                  caption: 'Un-Complete',
                  color: Colors.red,
                  icon: Icons.check,
                  onTap: () {
                    GuideModel guide =
                        Provider.of<GuideProvider>(context, listen: false)
                            .guide[widget.index];
                    guide.gameName = widget.game.gameName;
                    guide.gameImgUrl = widget.game.gameImageUrl;
                    Provider.of<InternalDbProvider>(context, listen: false)
                        .removeTrophyFromComplete(guide);
                    setState(() {
                      widget.isCompleted = false;
                    });
                    snackBar(
                        context,
                        'Un-Completed',
                        "${Provider.of<GuideProvider>(context, listen: false).guide[widget.index].trophyName} has been un-completed",
                        wp);
                  },
                ),
        ],
        secondaryActions: <Widget>[
          (!widget.isStarred)
              ? IconSlideAction(
                  caption: 'Star',
                  color: Colors.yellow,
                  icon: Icons.star,
                  onTap: () {
                    GuideModel guide =
                        Provider.of<GuideProvider>(context, listen: false)
                            .guide[widget.index];
                    guide.gameName = widget.game.gameName;
                    guide.gameImgUrl = widget.game.gameImageUrl;
                    Provider.of<InternalDbProvider>(context, listen: false)
                        .addTrophyToStarred(guide);
                    setState(() {
                      widget.isStarred = true;
                    });
                    snackBar(
                        context,
                        'Starred',
                        "${Provider.of<GuideProvider>(context, listen: false).guide[widget.index].trophyName} has been starred",
                        wp);
                  },
                )
              : IconSlideAction(
                  caption: 'Un-Star',
                  color: Colors.red,
                  icon: Icons.star,
                  onTap: () {
                    GuideModel guide =
                        Provider.of<GuideProvider>(context, listen: false)
                            .guide[widget.index];
                    guide.gameName = widget.game.gameName;
                    guide.gameImgUrl = widget.game.gameImageUrl;
                    Provider.of<InternalDbProvider>(context, listen: false)
                        .removeTrophyFromStarred(guide);
                    setState(() {
                      widget.isStarred = false;
                    });
                    snackBar(
                        context,
                        'Un-Starred',
                        "${Provider.of<GuideProvider>(context, listen: false).guide[widget.index].trophyName} has been un-starred",
                        wp);
                  },
                ),
        ],
      ),
    );
  }
}
