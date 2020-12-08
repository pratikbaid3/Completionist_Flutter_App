import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_trophy_manager/BloC/Game/game_bloc.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:neumorphic/neumorphic.dart';
import '../Utilities/external_db_helper.dart';
import '../Utilities/reusable_elements.dart';
import '../Utilities/checklist_helper.dart';
import '../Utilities/internal_db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrophyPage extends StatefulWidget {
  TrophyPage({this.gameName, this.gameImageIcon});
  final gameName;
  final gameImageIcon;

  @override
  _TrophyPageState createState() => _TrophyPageState();
}

class _TrophyPageState extends State<TrophyPage> {
  List<List<String>> trophyData;
  External_Database_Manager externalDbManager;
  Internal_Database_Manager internalDbManager;
  ChecklistManager checklistManager;

  bool isSwitched = false;
  int gameAdded = 0;
  int achievedTrophies = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    externalDbManager = new External_Database_Manager();
    internalDbManager = new Internal_Database_Manager();
    buildList();
  }

  void buildList() async {
    trophyData = await externalDbManager.getTrophyData(widget.gameName);
    checklistManager = new ChecklistManager(noOfElements: trophyData[0].length);
    checklistManager.buildList();
    var achievedTrophyChecklist =
        await internalDbManager.checkIfGameIsAdded(widget.gameName);
    setState(() {
      if (achievedTrophyChecklist.length == 1) {
        gameAdded = 0;
      } else {
        gameAdded = 1;
        checklistManager.isSwitcher = achievedTrophyChecklist;
      }
    });
    print(trophyData[2][0]);
  }

  Widget trophyType(index) {
    String platinum = '1';
    String gold = '2';
    String silver = '3';
    String bronze = '4';
    if (trophyData[2][index] == platinum || trophyData[2][index] == gold) {
      return Icon(
        LineAwesomeIcons.trophy,
        color: Color(0xffD4AF37),
        size: 40,
      );
    } else if (trophyData[2][index] == silver) {
      return Icon(
        LineAwesomeIcons.trophy,
        color: Color(0xffC0C0C0),
        size: 40,
      );
    }
    return Icon(
      LineAwesomeIcons.trophy,
      color: Color(0xffb08d57),
      size: 40,
    );
  }

  void saveSharedPreferences(index, type) async {
    String platinum = '1';
    String gold = '2';
    String silver = '3';
    if (type == 'add') {
      if (trophyData[2][index] == platinum || trophyData[2][index] == gold) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int gold = (prefs.getInt('gold') ?? 0) + 1;
        await prefs.setInt('gold', gold);
      } else if (trophyData[2][index] == silver) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int silver = (prefs.getInt('silver') ?? 0) + 1;
        await prefs.setInt('silver', silver);
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int bronze = (prefs.getInt('bronze') ?? 0) + 1;

        await prefs.setInt('bronze', bronze);
      }
    } else {
      if (trophyData[2][index] == platinum || trophyData[2][index] == gold) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int gold = (prefs.getInt('gold') ?? 0) - 1;

        await prefs.setInt('gold', gold);
      } else if (trophyData[2][index] == silver) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int silver = (prefs.getInt('silver') ?? 0) - 1;

        await prefs.setInt('silver', silver);
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int bronze = (prefs.getInt('bronze') ?? 0) - 1;
        await prefs.setInt('bronze', bronze);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 70, bottom: 30, left: 30, right: 30),
            child: NeuCard(
              curveType: CurveType.flat,
              bevel: 10,
              decoration: NeumorphicDecoration(
                borderRadius: BorderRadius.circular(8),
                color: backgroundColor,
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Hero(
                  tag: '${widget.gameImageIcon}',
                  child: Image(
                    image: NetworkImage(
                      widget.gameImageIcon,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: NeuSwitch<int>(
              thumbColor: accentColor,
              backgroundColor: backgroundColor,
              onValueChanged: (val) {
                final weatherBloc = BlocProvider.of<GameBloc>(context);
                weatherBloc.add(GetGameList());
                setState(() {
                  if (gameAdded == 0) {
                    gameAdded = 1;

                    internalDbManager.addGameToDb(
                      widget.gameName,
                      checklistManager.isSwitcher,
                      0,
                      checklistManager.isSwitcher.length,
                      widget.gameImageIcon,
                    );
                  } else {
                    gameAdded = 0;
                    internalDbManager.deleteGameFromDb(widget.gameName);
                  }
                });
              },
              groupValue: gameAdded,
              children: {
                0: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
                1: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                  child: Icon(
                    Icons.add,
                    color: Colors.green,
                  ),
                ),
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: externalDbManager.getGameName(),
              builder: (context, snapshot) {
                Widget x;

                if (snapshot.hasData) {
                  x = ListView.builder(
                      padding: EdgeInsets.only(top: 0),
                      itemCount: trophyData[0].length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return new Card(
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 8.0,
                          margin: new EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 13.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: new BorderRadius.all(
                                  const Radius.circular(10)),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              leading: Container(
                                padding: EdgeInsets.only(right: 12.0),
                                decoration: new BoxDecoration(
                                    border: new Border(
                                        right: new BorderSide(
                                            width: 1.0,
                                            color: Colors.white24))),
                                child: NeuCard(
                                    curveType: CurveType.flat,
                                    bevel: 8,
                                    decoration: NeumorphicDecoration(
                                      color: accentColor,
                                    ),
                                    child: SizedBox(
                                      child: Center(
                                        child: trophyType(index),
                                      ),
                                      height: 55,
                                      width: 55,
                                    )),
                              ),
                              title: Text(
                                '${trophyData[0][index]}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              trailing: Switch(
                                value: checklistManager.isSwitcher[index],
                                onChanged: (value) {
                                  setState(() {
                                    if (gameAdded == 1) {
                                      checklistManager.isSwitcher[index] =
                                          value;
                                      if (value) {
                                        achievedTrophies++;
                                        saveSharedPreferences(index, 'add');
                                      } else {
                                        achievedTrophies--;
                                        saveSharedPreferences(index, 'remove');
                                      }
                                      internalDbManager.updateCheckList(
                                          checklistManager.isSwitcher,
                                          achievedTrophies,
                                          widget.gameName);
                                      //updateGameFromFirebase();
                                      print(checklistManager.isSwitcher);
                                    } else {
                                      checklistManager.isSwitcher[index] =
                                          !value;
                                    }
                                  });
                                },
                                activeTrackColor: Colors.lightGreenAccent,
                                activeColor: Colors.green,
                              ),
                              subtitle: Text(trophyData[1][index],
                                  style: TextStyle(color: Colors.white)),
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
      ),
    );
  }
}
