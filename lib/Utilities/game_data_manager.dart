import 'package:game_trophy_manager/Utilities/internal_db_helper.dart';

abstract class GameDataManager {
  Future fetchAddedGames();
}

class GameData implements GameDataManager {
  @override
  Future fetchAddedGames() async {
    Internal_Database_Manager internalDbManager =
        new Internal_Database_Manager();
    List<Map> internalAddedGame = await internalDbManager.getAllGamesAdded();
    for (var data in internalAddedGame) {
      double gameCompletePercentage =
          data['NoOfAchievedTrophy'] / data['TotalTrophy'];
      String gameName = data['GameName'];
      String gameImageLink = data['GameIconImageLink'];
    }
  }
}
