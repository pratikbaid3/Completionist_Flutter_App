import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:game_trophy_manager/Model/game_model.dart';
import 'package:game_trophy_manager/Utilities/api.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PS4GameProvider extends ChangeNotifier {
  Future getGame(
      {int pageKey = 1,
      String search = '',
      @required PagingController pagingController}) async {
    try {
      print('--GET GAMES--');
      print(baseUrl +
          gamesUrl +
          '?page=' +
          pageKey.toString() +
          '&search=' +
          search);
      Response response;
      Dio dio = new Dio();
      response = await dio.get(baseUrl + gamesUrl,
          queryParameters: {"page": pageKey, "search": search});
      print(response.data);
      List<dynamic> data = response.data['results'];
      List<GameModel> newGames =
          data.map((data) => GameModel.fromJson(data)).toList();
      bool isLastPage = newGames.length < 30;
      if (isLastPage) {
        pagingController.appendLastPage(newGames);
      } else {
        final nextPageKey = pageKey + 1;
        pagingController.appendPage(newGames, nextPageKey);
      }
    } catch (e) {
      pagingController.error = e;
      print(e);
    }
  }
}
