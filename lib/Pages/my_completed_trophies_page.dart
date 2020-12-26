import 'package:cached_network_image/cached_network_image.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:game_trophy_manager/Provider/guide_provider.dart';
import 'package:game_trophy_manager/Provider/internal_db_provider.dart';
import 'package:game_trophy_manager/Router/router_constant.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

class MyCompletedTrophyPage extends StatefulWidget {
  @override
  _MyCompletedTrophyPageState createState() => _MyCompletedTrophyPageState();
}

class _MyCompletedTrophyPageState extends State<MyCompletedTrophyPage> {
  TextEditingController searchController = new TextEditingController();
  String searchKeyword = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isExpanded = false;
    double hp = MediaQuery.of(context).size.height;
    double wp = MediaQuery.of(context).size.width;
    return KeyboardDismissOnTap(
      child: Scaffold(
        body: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: wp * 0.03, vertical: hp * 0.03),
          child: (Provider.of<InternalDbProvider>(context)
                      .myCompletedTrophy
                      .length !=
                  0)
              ? Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        padding: EdgeInsets.only(top: 10, left: 2, right: 2),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    LineAwesomeIcons.trophy,
                                    size: 30,
                                    color: (Provider.of<InternalDbProvider>(
                                                    context)
                                                .myCompletedTrophy[index]
                                                .trophyType ==
                                            'BRONZE')
                                        ? bronzeColor
                                        : ((Provider.of<InternalDbProvider>(
                                                        context)
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
                                      imageUrl: Provider.of<InternalDbProvider>(
                                              context)
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
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'images/no_data.svg',
                        width: wp * 0.7,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
