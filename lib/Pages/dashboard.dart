import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_trophy_manager/Provider/guide_provider.dart';
import 'package:game_trophy_manager/Provider/internal_db_provider.dart';
import 'package:game_trophy_manager/Router/router_constant.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:game_trophy_manager/Widgets/line_chart.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Widget> recentGames = [];
  @override
  Widget build(BuildContext context) {
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
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LineChartSample2(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
