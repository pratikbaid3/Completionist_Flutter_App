import 'package:game_trophy_manager/Model/game.dart';
import 'package:game_trophy_manager/Utilities/internal_db_helper.dart';

abstract class GameDataManager {
  Future<List<Game>> fetchAddedGames();
}

class GameData implements GameDataManager {
  @override
  Future<List<Game>> fetchAddedGames() async {
    Internal_Database_Manager internalDbManager =
        new Internal_Database_Manager();
    List<Map> internalAddedGame = await internalDbManager.getAllGamesAdded();
    List<Game> addedGames = [];
    for (var data in internalAddedGame) {
      double gameCompletePercentage =
          data['NoOfAchievedTrophy'] / data['TotalTrophy'];
      String gameName = data['GameName'];
      String gameImageLink = data['GameIconImageLink'];
      Game game = new Game(
          gameName: gameName,
          gameCompletionPercentage: gameCompletePercentage,
          gameImageLink: gameImageLink);
      addedGames.add(game);
    }
    return addedGames;
  }
}
