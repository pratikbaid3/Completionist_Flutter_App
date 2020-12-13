import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:game_trophy_manager/Model/game_model.dart';
import 'package:game_trophy_manager/Utilities/api.dart';

class GameProvider extends ChangeNotifier {
  List<GameModel> games = new List<GameModel>();
  Future getGame({int page = 1, int count = 30, String search = ''}) async {
    try {
      Response response;
      Dio dio = new Dio();
      response = await dio.get(baseUrl + getAllPs4Games,
          queryParameters: {"page": page, "count": count, "search": search});
      List<dynamic> data = response.data['result']['games'];
      List<GameModel> tempGames =
          data.map((data) => GameModel.fromJson(data)).toList();
      if (page == 1) {
        games.clear();
      }
      for (GameModel i in tempGames) {
        games.add(i);
      }
    } catch (e) {
      print(e);
    }
  }
}
