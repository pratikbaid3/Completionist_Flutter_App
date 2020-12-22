import 'package:flutter/cupertino.dart';
import 'package:game_trophy_manager/Model/game_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class InternalDbProvider extends ChangeNotifier {
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

  List<GameModel> myGames = new List<GameModel>();

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
        'CREATE TABLE $myGamesTable($gameNameColumn TEXT PRIMARY KEY UNIQUE, $gameImgUrlColumn TEXT)');
    await db.execute(
        'CREATE TABLE $myTrophyTable($gameNameColumn TEXT PRIMARY KEY UNIQUE, $gameImgUrlColumn TEXT,$trophyNameColumn TEXT,$trophyImageUrlColumn TEXT,$trophyTypeColumn TEXT,$trophyDescriptionColumn TEXT,$trophyGuideColumn TEXT)');
  }

  void addGameToDb(GameModel game) async {
    try {
      String gameName = game.gameName;
      String gameImgUrl = game.gameImageUrl;
      var dbClient = await db; //This calls the getter function
      var result = await dbClient.rawInsert(
          'INSERT INTO $myGamesTable($gameNameColumn, $gameImgUrlColumn) '
          'VALUES("$gameName","$gameImgUrl")');
      myGames.add(game);
      notifyListeners();
      print(result);
    } catch (e) {
      print(e);
    }
  }

  void removeGameFromDb(GameModel game) async {
    try {
      print(game.gameName);
      String gameName = game.gameName;
      var dbClient = await db;
      var result = await dbClient.rawDelete(
          'DELETE FROM $myGamesTable WHERE $gameNameColumn = "${game.gameName}"');
      myGames.removeWhere((element) {
        if (element.gameName == gameName) {
          return true;
        }
        return false;
      });
      notifyListeners();
      print(result);
    } catch (e) {
      print(e);
    }
  }

  void getAllGamesFromDb() async {
    try {
      var dbClient = await db;
      List<Map> result = await dbClient.rawQuery('SELECT * FROM $myGamesTable');
      if (result.length > 0) {
        for (var i in result) {
          GameModel game = new GameModel(
              gameName: i['$gameNameColumn'],
              gameImageUrl: i['$gameImgUrlColumn']);
          myGames.add(game);
          print(i['$gameNameColumn']);
        }
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }
}
