import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:game_trophy_manager/Model/game_model.dart';
import 'package:game_trophy_manager/Utilities/api.dart';

class GameProvider extends ChangeNotifier {
  Future<List<GameModel>> getGame() async {
    Response response;
    Dio dio = new Dio();
    response =
        await dio.get('https://completionist-api.herokuapp.com/ps4/games',
            options: Options(
                followRedirects: false,
                validateStatus: (status) {
                  return status < 500;
                }));
    List<dynamic> data = response.data['result']['games'];
    List<GameModel> games =
        data.map((data) => GameModel.fromJson(data)).toList();
    return games;
  }
}
