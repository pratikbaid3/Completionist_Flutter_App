import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_trophy_manager/Provider/ad_state_provider.dart';
import 'package:game_trophy_manager/Provider/in_app_purchase_provider.dart';
import 'package:game_trophy_manager/Provider/ps4_guide_provider.dart';
import 'package:game_trophy_manager/Provider/internal_db_provider.dart';
import 'package:game_trophy_manager/Router/router_constant.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:game_trophy_manager/Widgets/ps4_guide_card_dashboard.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  BuildContext myContext;
  BannerAd bannerAd;
  GlobalKey initialGuideKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Future.delayed(
        Duration(milliseconds: 200),
        () async {
          ShowCaseWidget.of(myContext).startShowCase([initialGuideKey]);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          bool isInitialGuideShown =
              prefs.getBool('initial_guide_showed') ?? false;
          if (!isInitialGuideShown) {
            await prefs.setBool('initial_guide_showed', true);
            ShowCaseWidget.of(myContext).startShowCase([initialGuideKey]);
          }
        },
      ),
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (!Provider.of<InAppPurchaseProvider>(context)
        .isPremiumVersionPurchased) {
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
    return ShowCaseWidget(
      builder: Builder(
        builder: (context) {
          myContext = context;
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
                                    decoration:
                                        BoxDecoration(color: primaryColor),
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
                                  decoration:
                                      BoxDecoration(color: primaryColor),
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
                  (bannerAd != null &&
                          !Provider.of<InAppPurchaseProvider>(context)
                              .isPremiumVersionPurchased)
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
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
                            return PS4GuideCardDashboard(
                              isExpanded: isExpanded,
                              index: index,
                              onExpanded: (value) {
                                setState(() {
                                  isExpanded = value;
                                });
                              },
                            );
                          },
                        )
                      : Center(
                          child: Showcase(
                            targetBorderRadius: BorderRadius.circular(25),
                            tooltipBackgroundColor: Color(0xff2096F3),
                            textColor: Colors.white,
                            key: initialGuideKey,
                            title: 'Find Games',
                            description:
                                'Find your favourite games and add them to your library',
                            titlePadding:
                                EdgeInsets.only(left: 12, right: 12, top: 12),
                            descriptionPadding: EdgeInsets.all(12),
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 30, horizontal: 30),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed(ps4GamePageRoute);
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 15.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(FontAwesomeIcons.playstation),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        "Find Games",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Icon(FontAwesomeIcons.xbox),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
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
                  (Provider.of<InternalDbProvider>(context)
                              .myStarredTrophy
                              .length !=
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      LineAwesomeIcons.trophy,
                                      size: 30,
                                      color: (Provider.of<InternalDbProvider>(
                                                      context)
                                                  .myStarredTrophy[index]
                                                  .trophyType ==
                                              'BRONZE')
                                          ? bronzeColor
                                          : ((Provider.of<InternalDbProvider>(
                                                          context)
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
                                            Provider.of<InternalDbProvider>(
                                                    context)
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
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 20),
                                  )
                                ],
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 30),
                            child: ElevatedButton(
                              onPressed: () {},
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 15.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(FontAwesomeIcons.playstation),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "Find Games",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Icon(FontAwesomeIcons.xbox),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                  SizedBox(height: 100)
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
