import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_trophy_manager/Provider/guide_provider.dart';
import 'package:game_trophy_manager/Provider/internal_db_provider.dart';
import 'package:game_trophy_manager/Router/router_constant.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:game_trophy_manager/Widgets/line_chart.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Widget> recentGames = [];
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    double hp = MediaQuery.of(context).size.height;
    double wp = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
            ),
            (Provider.of<InternalDbProvider>(context).myGames.length != 0)
                ? CarouselSlider(
                    viewportFraction: 0.48,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    pauseAutoPlayOnTouch: Duration(seconds: 2),
                    items: Provider.of<InternalDbProvider>(context)
                        .myGames
                        .map((i) {
                      return Builder(
                        builder: (BuildContext context) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(guidePageRoute, arguments: i)
                                  .then((value) {
                                Provider.of<GuideProvider>(context,
                                        listen: false)
                                    .clearGuideList();
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(color: primaryColor),
                              child: NeuCard(
                                curveType: CurveType.flat,
                                bevel: 4,
                                decoration: NeumorphicDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: primaryColor,
                                ),
                                child: ClipRRect(
                                  child: Padding(
                                    padding: EdgeInsets.all(15),
                                    child: CachedNetworkImage(
                                      imageUrl: i.gameImageUrl,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  )
                : CarouselSlider(
                    viewportFraction: 0.48,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    pauseAutoPlayOnTouch: Duration(seconds: 2),
                    items: [1, 2].map((i) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(color: primaryColor),
                            child: NeuCard(
                              width: 178,
                              curveType: CurveType.flat,
                              bevel: 4,
                              decoration: NeumorphicDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: primaryColor,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  (i == 1)
                                      ? FontAwesomeIcons.playstation
                                      : FontAwesomeIcons.xbox,
                                  size: 70,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                children: [
                  Text(
                    'Achievement ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: wp * 0.055,
                    ),
                  ),
                  Text(
                    'Stats',
                    style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: wp * 0.055),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LineChartSample2(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: Row(
                children: [
                  Text(
                    'Recent ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: wp * 0.055,
                    ),
                  ),
                  Text(
                    'Activity',
                    style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: wp * 0.055),
                  ),
                ],
              ),
            ),
            (Provider.of<InternalDbProvider>(context).myTrophy.length != 0)
                ? ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(
                        top: 10, left: wp * 0.03, right: wp * 0.03),
                    itemCount: (Provider.of<InternalDbProvider>(context)
                                .myTrophy
                                .length >
                            5)
                        ? 5
                        : Provider.of<InternalDbProvider>(context)
                            .myTrophy
                            .length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
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
                                color: (Provider.of<InternalDbProvider>(context)
                                            .myTrophy[index]
                                            .trophyType ==
                                        'BRONZE')
                                    ? bronzeColor
                                    : ((Provider.of<InternalDbProvider>(context)
                                                .myTrophy[index]
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
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 13.0),
                            leading: Container(
                                padding: EdgeInsets.only(right: 12.0),
                                decoration: new BoxDecoration(
                                    border: new Border(
                                        right: new BorderSide(
                                            width: 1.0,
                                            color: Colors.white24))),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      Provider.of<InternalDbProvider>(context)
                                          .myTrophy[index]
                                          .trophyImage,
                                  placeholder: (context, url) =>
                                      new CircularProgressIndicator(
                                    backgroundColor: primaryAccentColor,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      new Icon(Icons.error),
                                )),
                            title: Text(
                              '${Provider.of<InternalDbProvider>(context).myTrophy[index].trophyName}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                Provider.of<InternalDbProvider>(context)
                                    .myTrophy[index]
                                    .trophyDescription,
                                style: TextStyle(
                                  color: Colors.white60,
                                ),
                              ),
                            ),
                          ),
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: HtmlWidget(
                                '''${Provider.of<InternalDbProvider>(context).myTrophy[index].trophyGuide}''',
                                textStyle: TextStyle(fontSize: 15),
                                webView: true,
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 20),
                            )
                          ],
                        ),
                      );
                    },
                  )
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: SvgPicture.asset(
                        'images/coming_soon.svg',
                        width: wp * 0.4,
                      ),
                    ),
                  ),
            SizedBox(height: 100)
          ],
        ),
      ),
    );
  }
}
