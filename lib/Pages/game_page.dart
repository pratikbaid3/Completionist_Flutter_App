import 'package:flutter/material.dart';
import 'dart:core';
import 'package:neumorphic/neumorphic.dart';
import '../Utilities/external_db_helper.dart';
import '../Utilities/util_class.dart';
import 'trophy_page.dart';
import '../Utilities/reusable_elements.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<List<String>> items;
  List<String> filteredGames;
  List<String> filteredGamesIcon;
  final _debouncer = Debouncer(milliseconds: 500);

  Map gameDetail = new Map();

  bool initialized = false;
  External_Database_Manager dbManager;

  @override
  void initState() {
    //TODO: implement initState
    super.initState();
    dbManager = new External_Database_Manager();
    buildList();
  }

  Future<void> convertListToMap() {
    int length = items[0].length;
    for (int i = 0; i < length; i++) {
      gameDetail[items[0][i]] = items[1][i];
    }
  }

  void buildList() async {
    items = await dbManager.getGameName();
    await convertListToMap();
    setState(() {
      filteredGames = items[0];
      filteredGamesIcon = items[1];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(left: 25, right: 25, top: 80, bottom: 20),
          child: NeuCard(
            curveType: CurveType.emboss,
            bevel: 16,
            decoration: NeumorphicDecoration(
              color: backgroundColor,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 4, bottom: 4),
                child: TextField(
                  cursorColor: Colors.white,
                  onChanged: (string) {
                    // TODO: check the change of the search bar here
                    _debouncer.run(() {
                      setState(() {
                        filteredGames = items[0]
                            .where((u) => (u
                                .toLowerCase()
                                .contains(string.toLowerCase())))
                            .toList();
                      });
                    });
                  },
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Which game?',
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: dbManager.getGameName(),
            builder: (context, snapshot) {
              Widget x;

              if (snapshot.hasData) {
                x = ListView.builder(
                    padding: EdgeInsets.only(top: 0),
                    itemCount: filteredGames.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return new Card(
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 8.0,
                        margin: new EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        child: new InkWell(
                          splashColor: Colors.white,
                          onTap: () {
                            print(filteredGames[index]);
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return TrophyPage(
                                  gameName: filteredGames[index],
                                  gameImageIcon:
                                      gameDetail[filteredGames[index]],
                                );
                              },
                            ));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: accentColor,
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
                                    tag: '${gameDetail[filteredGames[index]]}',
                                    child: Image(
                                      width: 90,
                                      height: 90,
                                      image: NetworkImage(
                                          gameDetail[filteredGames[index]]),
                                    ),
                                  )),
                              title: Text(
                                '${filteredGames[index]}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              trailing: Icon(Icons.keyboard_arrow_right,
                                  color: Colors.white, size: 30.0),
                              subtitle: Row(
                                children: <Widget>[
                                  Icon(Icons.linear_scale,
                                      color: Colors.yellowAccent),
                                  Text(" Intermediate",
                                      style: TextStyle(color: Colors.white))
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    });
              } else if (snapshot.hasError) {
                x = Center(
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                );
              } else {
                x = Center(
                  child: SizedBox(
                    child: CircularProgressIndicator(),
                    width: 60,
                    height: 60,
                  ),
                );
              }
              return x;
            },
          ),
        ),
      ],
    ));
  }
}
