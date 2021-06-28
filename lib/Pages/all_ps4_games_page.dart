import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_trophy_manager/Provider/game_provider.dart';
import 'package:game_trophy_manager/Provider/guide_provider.dart';
import 'package:game_trophy_manager/Router/router_constant.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

class AllPS4GamesPage extends StatefulWidget {
  @override
  _AllPS4GamesPageState createState() => _AllPS4GamesPageState();
}

class _AllPS4GamesPageState extends State<AllPS4GamesPage> {
  TextEditingController searchController = new TextEditingController();
  bool isSearchIcon = true;
  int currentPage;
  int nextPage;
  String searchKeyword = '';

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentPage = 1;
    nextPage = currentPage + 1;
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        int itemCount =
            Provider.of<GameProvider>(context, listen: false).games.length;
        if (itemCount == 30 * currentPage) {
          setState(() {
            currentPage += 1;
            nextPage += 1;
          });
        }
      }
    });
  }

  ScrollController _scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    double hp = MediaQuery.of(context).size.height;
    double wp = MediaQuery.of(context).size.width;
    return KeyboardDismissOnTap(
      child: Scaffold(
        body: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: wp * 0.03, vertical: hp * 0.03),
            child: Column(
              children: [
                TextField(
                  onSubmitted: (value) {
                    setState(() {
                      searchKeyword = searchController.text;
                      currentPage = 1;
                      nextPage = currentPage + 1;
                      isSearchIcon = false;
                    });
                  },
                  cursorColor: primaryAccentColor,
                  controller: searchController,
                  decoration: InputDecoration(
                    suffixIcon: (isSearchIcon)
                        ? IconButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                searchKeyword = searchController.text;
                                currentPage = 1;
                                nextPage = currentPage + 1;
                                isSearchIcon = false;
                              });
                            },
                            icon: Icon(
                              Icons.search,
                              color: Colors.white54,
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                isSearchIcon = true;
                                currentPage = 1;
                                nextPage = currentPage + 1;
                                searchController.text = '';
                                searchKeyword = searchController.text;
                              });
                              //TODO Execute search
                            },
                            icon: Icon(
                              Icons.close,
                              color: Colors.white54,
                            ),
                          ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: primaryAccentColor,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: primaryColor,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    filled: true,
                    fillColor: secondaryColor,
                    hintText: "Search",
                    contentPadding: EdgeInsets.only(
                        left: 20, bottom: 20, top: 20, right: 20),
                  ),
                ),
                SizedBox(
                  height: hp * 0.02,
                ),
                Expanded(
                  child: FutureBuilder(
                    future: Provider.of<GameProvider>(context)
                        .getGame(page: currentPage, search: searchKeyword),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (Provider.of<GameProvider>(context).games.length ==
                          0) {
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
                        controller: _scrollController,
                        primary: false,
                        shrinkWrap: true,
                        padding: EdgeInsets.only(top: 10, left: 2, right: 2),
                        itemCount:
                            Provider.of<GameProvider>(context).games.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                            margin: new EdgeInsets.symmetric(vertical: 10.0),
                            child: GestureDetector(
                              onTap: () {
                                Provider.of<GuideProvider>(context,
                                        listen: false)
                                    .clearGuideList();
                                Navigator.of(context)
                                    .pushNamed(guidePageRoute,
                                        arguments: Provider.of<GameProvider>(
                                                context,
                                                listen: false)
                                            .games[index])
                                    .then((value) {
                                });
                              },
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
                                            '${Provider.of<GameProvider>(context).games[index].gameName}',
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              Provider.of<GameProvider>(context)
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
                                              LineAwesomeIcons.trophy,
                                              color: goldenColor,
                                              size: 25,
                                            ),
                                            Text(
                                              ' ' +
                                                  Provider.of<GameProvider>(
                                                          context)
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
                                                  Provider.of<GameProvider>(
                                                          context)
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
                                                  Provider.of<GameProvider>(
                                                          context)
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
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
