import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class GraphProvider extends ChangeNotifier {
  static Database _db;
  final String dbName = 'Games.db';
  final String myGamesTable = 'MyGames';
  final String myTrophyTable = 'MyTrophy';
  final String gameNameColumn = 'GameName';
  final String gameImgUrlColumn = 'GameImgUrl';
  final String trophyNameColumn = 'TrophyName';
  final String trophyImageUrlColumn = 'TrophyImgUrl';
  final String trophyTypeColumn = 'TrophyType';
  final String trophyDescriptionColumn = 'TrophyDescription';
  final String trophyGuideColumn = 'TrophyGuide';
  final String trophyActionColumn = 'TrophyAction'; //Starred or Completed
  final String dateTimeColumn = 'DateTime';
  final String goldColumn = 'GOLD';
  final String silverColumn = 'SILVER';
  final String bronzeColumn = 'BRONZE';

  double jan = 0;
  double feb = 0;
  double march = 0;
  double april = 0;
  double may = 0;
  double june = 0;
  double july = 0;
  double aug = 0;
  double sept = 0;
  double oct = 0;
  double nov = 0;
  double dec = 0;

  double yAxis = 1;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dbName);
    print(path);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $myGamesTable($gameNameColumn TEXT PRIMARY KEY UNIQUE, $gameImgUrlColumn TEXT,$dateTimeColumn DATETIME,$goldColumn TEXT, $silverColumn TEXT, $bronzeColumn TEXT)');
    await db.execute(
        'CREATE TABLE $myTrophyTable($gameNameColumn TEXT, $gameImgUrlColumn TEXT,$trophyNameColumn TEXT,$trophyImageUrlColumn TEXT,$trophyTypeColumn TEXT,$trophyDescriptionColumn TEXT,$trophyGuideColumn TEXT,$trophyActionColumn TEXT,$dateTimeColumn DATETIME)');
  }

  void getAllTrophyDateFromDb() async {
    try {
      var dbClient = await db;
      List<Map> result = await dbClient.rawQuery(
          'SELECT * FROM $myTrophyTable ORDER BY $dateTimeColumn DESC');
      if (result.length > 0) {
        for (var i in result) {
          DateTime date = DateTime.parse(i['$dateTimeColumn']);
          if (date.month == 1) {
            jan += 1;
          } else if (date.month == 2) {
            feb += 1;
          } else if (date.month == 3) {
            march += 1;
          } else if (date.month == 4) {
            april += 1;
          } else if (date.month == 5) {
            may += 1;
          } else if (date.month == 6) {
            june += 1;
          } else if (date.month == 7) {
            july += 1;
          } else if (date.month == 8) {
            aug += 1;
          } else if (date.month == 9) {
            sept += 1;
          } else if (date.month == 10) {
            oct += 1;
          } else if (date.month == 11) {
            nov += 1;
          } else if (date.month == 12) {
            dec += 1;
          }
        }
        yAxis = [
          jan,
          feb,
          march,
          april,
          may,
          june,
          july,
          aug,
          sept,
          oct,
          nov,
          dec
        ].reduce(max);

        yAxis = (yAxis + 5) / 6;
        if (yAxis == 0) {
          yAxis = 6 / 6;
        }
        print(yAxis);
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }
}
