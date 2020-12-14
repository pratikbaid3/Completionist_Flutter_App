import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:game_trophy_manager/Model/game_guide_model.dart';
import 'package:game_trophy_manager/Utilities/api.dart';

class GuideProvider extends ChangeNotifier {
  List<GuideModel> guide = new List<GuideModel>();
  Future getGuide({String gameName = ''}) async {
    try {
      Response response;
      Dio dio = new Dio();
      print('--GET GUIDE--');
      print(baseUrl + guideUrl + gameName);
      response = await dio.get(baseUrl + guideUrl + gameName);
      List<dynamic> data = response.data['result']['games']['guide'];
      guide = data.map((data) => GuideModel.fromJson(data)).toList();
    } catch (e) {
      print(e);
    }
  }
}