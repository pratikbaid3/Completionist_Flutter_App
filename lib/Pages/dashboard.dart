import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_trophy_manager/Provider/ad_state_provider.dart';
import 'package:game_trophy_manager/Provider/ps4_guide_provider.dart';
import 'package:game_trophy_manager/Provider/internal_db_provider.dart';
import 'package:game_trophy_manager/Router/router_constant.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  BannerAd bannerAd;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final adState = Provider.of<AdStateProvider>(context);
    adState.initialization.then((status) {
      setState(() {
        bannerAd = BannerAd(
          adUnitId: adState.bannerAdUnitId,
          size: AdSize.banner,
          request: AdRequest(),
          listener: BannerAdListener(),
        )..load();
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    bannerAd.dispose();
    super.dispose();
  }

  List<Widget> recentGames = [];
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
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
                    options: CarouselOptions(
                      viewportFraction: 0.48,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      autoPlayInterval: Duration(seconds: 2),
                    ),
                    items: Provider.of<InternalDbProvider>(context)
                        .myGames
                        .map((i) {
                      return Builder(
                        builder: (BuildContext context) {
                          return GestureDetector(
                            onTap: () {
                              Provider.of<PS4GuideProvider>(context,
                                      listen: false)
                                  .clearGuideList();
                              Navigator.of(context)
                                  .pushNamed(guidePageRoute, arguments: i)
                                  .then((value) {});
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(color: primaryColor),
                              child: Neumorphic(
                                style: NeumorphicStyle(
                                  surfaceIntensity: 0,
                                  depth: 6,
                                  lightSource: LightSource.topLeft,
                                  color: primaryColor,
                                  shape: NeumorphicShape.flat,
                                  shadowDarkColor: Color(0xff232831),
                                  shadowLightColor: Color(0xff2B313C),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(15),
                                  child: CachedNetworkImage(
                                    imageUrl: i.gameImageUrl,
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
                    options: CarouselOptions(
                      viewportFraction: 0.48,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      autoPlayInterval: Duration(seconds: 2),
                    ),
                    items: [1, 2].map((i) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(color: primaryColor),
                            child: Neumorphic(
                              style: NeumorphicStyle(
                                surfaceIntensity: 0,
                                depth: 6,
                                lightSource: LightSource.topLeft,
                                color: primaryColor,
                                shape: NeumorphicShape.flat,
                                shadowDarkColor: Color(0xff232831),
                                shadowLightColor: Color(0xff2B313C),
                              ),
                              child: Container(
                                width: 178,
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
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
            (bannerAd != null)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(width: double.infinity, height: 10),
                      Container(
                        alignment: Alignment.center,
                        child: AdWidget(ad: bannerAd),
                        width: bannerAd.size.width.toDouble(),
                        height: bannerAd.size.height.toDouble(),
                      ),
                      Container(width: double.infinity, height: 10),
                    ],
                  )
                : Container(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: Row(
                children: [
                  Text(
                    'Recently ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: wp * 0.055,
                    ),
                  ),
                  Text(
                    'Completed',
                    style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: wp * 0.055),
                  ),
                ],
              ),
            ),
            (Provider.of<InternalDbProvider>(context)
                        .myCompletedTrophy
                        .length !=
                    0)
                ? ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(
                        top: 10, left: wp * 0.03, right: wp * 0.03),
                    itemCount: (Provider.of<InternalDbProvider>(context)
                                .myCompletedTrophy
                                .length >
                            5)
                        ? 5
                        : Provider.of<InternalDbProvider>(context)
                            .myCompletedTrophy
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
                                            .myCompletedTrophy[index]
                                            .trophyType ==
                                        'BRONZE')
                                    ? bronzeColor
                                    : ((Provider.of<InternalDbProvider>(context)
                                                .myCompletedTrophy[index]
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
                                          .myCompletedTrophy[index]
                                          .trophyImage,
                                  placeholder: (context, url) =>
                                      new CircularProgressIndicator(
                                    backgroundColor: primaryAccentColor,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      new Icon(Icons.error),
                                )),
                            title: Text(
                              '${Provider.of<InternalDbProvider>(context).myCompletedTrophy[index].trophyName}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                Provider.of<InternalDbProvider>(context)
                                    .myCompletedTrophy[index]
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
                                '''${Provider.of<InternalDbProvider>(context).myCompletedTrophy[index].trophyGuide}''',
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
                      child: Image(
                        width: wp * 0.35,
                        image: AssetImage(
                          'images/no_data_2.png',
                        ),
                      ),
                    ),
                  ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: Row(
                children: [
                  Text(
                    'Recently ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: wp * 0.055,
                    ),
                  ),
                  Text(
                    'Starred',
                    style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: wp * 0.055),
                  ),
                ],
              ),
            ),
            (Provider.of<InternalDbProvider>(context).myStarredTrophy.length !=
                    0)
                ? ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(
                        top: 10, left: wp * 0.03, right: wp * 0.03),
                    itemCount: (Provider.of<InternalDbProvider>(context)
                                .myStarredTrophy
                                .length >
                            5)
                        ? 5
                        : Provider.of<InternalDbProvider>(context)
                            .myStarredTrophy
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
                                            .myStarredTrophy[index]
                                            .trophyType ==
                                        'BRONZE')
                                    ? bronzeColor
                                    : ((Provider.of<InternalDbProvider>(context)
                                                .myStarredTrophy[index]
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
                                          .myStarredTrophy[index]
                                          .trophyImage,
                                  placeholder: (context, url) =>
                                      new CircularProgressIndicator(
                                    backgroundColor: primaryAccentColor,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      new Icon(Icons.error),
                                )),
                            title: Text(
                              '${Provider.of<InternalDbProvider>(context).myStarredTrophy[index].trophyName}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                Provider.of<InternalDbProvider>(context)
                                    .myStarredTrophy[index]
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
                                '''${Provider.of<InternalDbProvider>(context).myStarredTrophy[index].trophyGuide}''',
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
                      child: Image(
                        width: wp * 0.45,
                        image: AssetImage(
                          'images/no_data_1.png',
                        ),
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
