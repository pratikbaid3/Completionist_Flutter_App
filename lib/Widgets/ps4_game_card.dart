import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:game_trophy_manager/Provider/game_provider.dart';
import 'package:game_trophy_manager/Provider/guide_provider.dart';
import 'package:game_trophy_manager/Router/router_constant.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class PS4GameCard extends StatelessWidget {
  int index;

  PS4GameCard({@required this.index});

  @override
  Widget build(BuildContext context) {
    return FocusedMenuHolder(
      menuBoxDecoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(50)),
      menuWidth: MediaQuery.of(context).size.width * 0.5,
      menuItemExtent: 60,
      onPressed: () {},
      menuItems: [
        FocusedMenuItem(
          title: Text(
            'Torrent Details',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          trailingIcon: Icon(
            Icons.info_outline,
            color: Colors.black,
          ),
          onPressed: () {},
        ),
        FocusedMenuItem(
          title: Text(
            'Check Hash',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          trailingIcon: Icon(
            Icons.tag,
            color: Colors.black,
          ),
          onPressed: () {},
        ),
      ],
      child: Card(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
        margin: new EdgeInsets.symmetric(vertical: 10.0),
        child: GestureDetector(
          onTap: () {
            Provider.of<GuideProvider>(context, listen: false).clearGuideList();
            Navigator.of(context)
                .pushNamed(guidePageRoute,
                    arguments: Provider.of<GameProvider>(context, listen: false)
                        .games[index])
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
                          right: new BorderSide(
                              width: 1.0, color: Colors.white24))),
                  child: Hero(
                    tag:
                        '${Provider.of<GameProvider>(context).games[index].gameName}',
                    child: CachedNetworkImage(
                      imageUrl: Provider.of<GameProvider>(context)
                          .games[index]
                          .gameImageUrl,
                      placeholder: (context, url) =>
                          new CircularProgressIndicator(
                        backgroundColor: primaryAccentColor,
                      ),
                      errorWidget: (context, url, error) =>
                          new Icon(Icons.error),
                    ),
                  )),
              title: Text(
                '${Provider.of<GameProvider>(context).games[index].gameName}',
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
                          ' ' +
                              Provider.of<GameProvider>(context)
                                  .games[index]
                                  .gold,
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
                          ' ' +
                              Provider.of<GameProvider>(context)
                                  .games[index]
                                  .silver,
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
                          ' ' +
                              Provider.of<GameProvider>(context)
                                  .games[index]
                                  .bronze,
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
      ),
    );
  }
}
