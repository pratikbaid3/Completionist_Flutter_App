import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:game_trophy_manager/Model/game_model.dart';
import 'package:game_trophy_manager/Utilities/api.dart';

class GameProvider extends ChangeNotifier {
  List<GameModel> games = new List<GameModel>();
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

  Future getGame({int page = 1, int count = 30, String search = ''}) async {
    try {
      print('--GET GAMES--');
      print(baseUrl + gamesUrl);
      Response response;
      Dio dio = new Dio();
      response = await dio.get(baseUrl + gamesUrl,
          queryParameters: {"page": page, "count": count, "search": search});
      List<dynamic> data = response.data['results'];
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
