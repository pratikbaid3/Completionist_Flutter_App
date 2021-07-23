import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:game_trophy_manager/Model/game_guide_model.dart';
import 'package:game_trophy_manager/Utilities/api.dart';

class PS4GuideProvider extends ChangeNotifier {
  List<GuideModel> guide = <GuideModel>[];

  Future getGuide({String gameName = ''}) async {
    try {
      Response response;
      Dio dio = new Dio();
      if (guide.length == 0) {
        print('--GET GUIDE--');
        print(baseUrl + guideUrl + gameName);
        response = await dio.get(baseUrl + guideUrl + gameName);
        List<dynamic> data = response.data['result'];
        guide = data.map((data) => GuideModel.fromJson(data)).toList();
      }
    } catch (e) {
      print(e);
    }
  }

  void clearGuideList() {
    guide.clear();
  }
}
