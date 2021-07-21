import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:game_trophy_manager/Model/game_model.dart';
import 'package:game_trophy_manager/Utilities/api.dart';

class GameProvider extends ChangeNotifier {
  List<GameModel> games = <GameModel>[];

  Future getGame({int page = 1, String search = ''}) async {
    try {
      print('--GET GAMES--');
      print(baseUrl + gamesUrl);
      if (page == 1) {
        games.clear();
      }
      Response response;
      Dio dio = new Dio();
      response = await dio.get(baseUrl + gamesUrl,
          queryParameters: {"page": page, "search": search});
      List<dynamic> data = response.data['results'];
      List<GameModel> tempGames =
          data.map((data) => GameModel.fromJson(data)).toList();
      for (GameModel i in tempGames) {
        games.add(i);
      }
    } catch (e) {
      print(e);
    }
  }
}
