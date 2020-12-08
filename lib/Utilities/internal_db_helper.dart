import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Internal_Database_Manager {
  final String tableName = 'myTrophies';
  final String dbName = 'myTrophies.db';
  final String gameNameColumn = 'GameName';
  final String achivedTrophyListColumn = 'TrophyList';
  final String totalTrophyColumn = 'TotalTrophy';
  final String noOfAchievedTrophyColumn = 'NoOfAchievedTrophy';
  final String gameIconImageLinkColumn = 'GameIconImageLink';
  static Database _db;

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
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  void deleteDB() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dbName);
    await deleteDatabase(path);
  }

  void _onCreate(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $tableName($gameNameColumn TEXT PRIMARY KEY UNIQUE, $achivedTrophyListColumn TEXT, $noOfAchievedTrophyColumn INTEGER, $totalTrophyColumn INTEGER,$gameIconImageLinkColumn TEXT)');
  }

  void addGameToDb(
      String gameName,
      List<bool> trophyList,
      int noOfAchievedTrophies,
      int totalNumberOfTrophies,
      String gameIconLink) async {
    var dbClient = await db; //This calls the getter function
    String encodedTrophyList = await listEncoder(trophyList);
    var result = await dbClient.rawInsert(
        'INSERT INTO $tableName($gameNameColumn, $achivedTrophyListColumn, $noOfAchievedTrophyColumn,$totalTrophyColumn,$gameIconImageLinkColumn) '
        'VALUES("$gameName","$encodedTrophyList","$noOfAchievedTrophies","$totalNumberOfTrophies","$gameIconLink")');
    print(result);
  }

  void deleteGameFromDb(String gameName) async {
    var dbClient = await db;
    var result = await dbClient.rawDelete(
        'DELETE FROM $tableName WHERE $gameNameColumn = "$gameName"');
  }

  void updateCheckList(List<bool> newCheckList, int noOfAchievedTrophies,
      String gameName) async {
    String encodedChecklist = await listEncoder(newCheckList);
    var dbClient = await db;
    var result = await dbClient.rawUpdate(
        'UPDATE $tableName SET $achivedTrophyListColumn = "$encodedChecklist" , $noOfAchievedTrophyColumn = "$noOfAchievedTrophies" WHERE $gameNameColumn = "$gameName"');
    print(result);
  }

  Future<List<Map>> getAllGamesAdded() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery('SELECT * FROM $tableName');
    return result.toList();
  }

  Future<List<bool>> checkIfGameIsAdded(String gameName) async {
    var dbClient = await db;
    List<Map> result = await dbClient.rawQuery(
        'SELECT * FROM $tableName WHERE $gameNameColumn = "$gameName"');
    if (result.length > 0) {
      return (listDecoder(result[0]['$achivedTrophyListColumn']));
    }
    return [false];
  }

  Future<List<bool>> listDecoder(String encoded) async {
    List<bool> decoded = [];
    for (String x in encoded.split('|')) {
      if (x == 'true') {
        decoded.add(true);
      } else {
        decoded.add(false);
      }
    }
    return decoded;
  }

  Future<String> listEncoder(List<bool> trophiesList) async {
    String encoded = "";
    int len = trophiesList.length;
    for (int i = 0; i < len - 1; i++) {
      if (trophiesList[i]) {
        encoded += 'true|';
      } else {
        encoded += 'false|';
      }
    }
    if (trophiesList[len - 1]) {
      encoded += 'true';
    } else {
      encoded += 'false';
    }

    return encoded;
  }
}
