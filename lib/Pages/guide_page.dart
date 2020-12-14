import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_trophy_manager/Provider/game_provider.dart';
import 'package:game_trophy_manager/Provider/guide_provider.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:game_trophy_manager/Widgets/app_bar.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class GuidePage extends StatefulWidget {
  String game;
  GuidePage({@required this.game});
  @override
  _GuidePageState createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  @override
  Widget build(BuildContext context) {
    double hp = MediaQuery.of(context).size.height;
    double wp = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: BaseAppBar(
        appBar: AppBar(),
      ),
      body: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: wp * 0.03, vertical: hp * 0.03),
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder(
                  future: Provider.of<GuideProvider>(context)
                      .getGuide(gameName: widget.game),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (Provider.of<GuideProvider>(context).guide.length == 0) {
                      return Container(
                        height: hp * 0.6,
                        child: Center(
                          child: SpinKitFadingCircle(
                            color: primaryAccentColor,
                            size: 60.0,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      primary: false,
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 10),
                      itemCount:
                          Provider.of<GuideProvider>(context).guide.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 8.0,
                          margin: new EdgeInsets.symmetric(vertical: 10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: secondaryColor,
                              borderRadius: new BorderRadius.all(
                                  const Radius.circular(10)),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 13.0),
                              leading: Container(
                                  padding: EdgeInsets.only(right: 12.0),
                                  decoration: new BoxDecoration(
                                      border: new Border(
                                          right: new BorderSide(
                                              width: 1.0,
                                              color: Colors.white24))),
                                  child: Hero(
                                    tag:
                                        '${Provider.of<GuideProvider>(context).guide[index].trophyName}',
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          Provider.of<GuideProvider>(context)
                                              .guide[index]
                                              .trophyImage,
                                      placeholder: (context, url) =>
                                          new CircularProgressIndicator(
                                        backgroundColor: primaryAccentColor,
                                      ),
                                      errorWidget: (context, url, error) =>
                                          new Icon(Icons.error),
                                    ),
                                  )),
                              title: Text(
                                '${Provider.of<GuideProvider>(context).guide[index].trophyName}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
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
                                          FontAwesomeIcons.trophy,
                                          color: goldenColor,
                                          size: 12,
                                        ),
                                        Text(
                                          "  3",
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
                                          FontAwesomeIcons.trophy,
                                          color: silverColor,
                                          size: 12,
                                        ),
                                        Text(
                                          "  3",
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
                                          FontAwesomeIcons.trophy,
                                          color: bronzeColor,
                                          size: 12,
                                        ),
                                        Text(
                                          "  3",
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
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          )),
    );
  }
}
