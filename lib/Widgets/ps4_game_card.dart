import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:game_trophy_manager/Model/game_model.dart';
import 'package:game_trophy_manager/Provider/ps4_guide_provider.dart';
import 'package:game_trophy_manager/Router/router_constant.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class PS4GameCard extends StatelessWidget {
  GameModel game;

  PS4GameCard({@required this.game});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
      margin: new EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          Provider.of<PS4GuideProvider>(context, listen: false)
              .clearGuideList();
          Navigator.of(context)
              .pushNamed(guidePageRoute, arguments: game)
              .then((value) {});
        },
        child: Container(
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: new BorderRadius.all(const Radius.circular(10)),
          ),
          child: ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 13.0),
            leading: Container(
                padding: EdgeInsets.only(right: 12.0),
                decoration: new BoxDecoration(
                    border: new Border(
                        right:
                            new BorderSide(width: 1.0, color: Colors.white24))),
                child: Hero(
                  tag: '${game.gameName}',
                  child: CachedNetworkImage(
                    imageUrl: game.gameImageUrl,
                    placeholder: (context, url) =>
                        new CircularProgressIndicator(
                      backgroundColor: primaryAccentColor,
                    ),
                    errorWidget: (context, url, error) => new Icon(Icons.error),
                  ),
                )),
            title: Text(
              '${game.gameName}',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            trailing: Icon(Icons.keyboard_arrow_right,
                color: Colors.white, size: 30.0),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Row(
                children: [
                  Row(
                    children: <Widget>[
                      Icon(
                        LineAwesomeIcons.trophy,
                        color: goldenColor,
                        size: 25,
                      ),
                      Text(
                        ' ' + game.gold,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Icon(
                        LineAwesomeIcons.trophy,
                        color: silverColor,
                        size: 25,
                      ),
                      Text(
                        ' ' + game.silver,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Icon(
                        LineAwesomeIcons.trophy,
                        color: bronzeColor,
                        size: 25,
                      ),
                      Text(
                        ' ' + game.bronze,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
