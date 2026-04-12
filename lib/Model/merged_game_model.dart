import 'package:game_trophy_manager/Model/game_model.dart';
import 'package:game_trophy_manager/Model/psn_game_snapshot.dart';

class MergedGameModel {
  final GameModel? localGame;
  final PsnGameSnapshot? psnGame;
  final int localCompletedCount;
  final int localStarredCount;

  const MergedGameModel({
    this.localGame,
    this.psnGame,
    this.localCompletedCount = 0,
    this.localStarredCount = 0,
  });

  String get source {
    if (localGame != null && psnGame != null) return 'both';
    if (psnGame != null) return 'psn';
    return 'local';
  }

  String get gameName => localGame?.gameName ?? psnGame?.name ?? '';

  String get imageUrl => localGame?.gameImageUrl ?? psnGame?.imageUrl ?? '';

  String get platform {
    final rawPlatform = (localGame?.platform ?? psnGame?.platform ?? '')
        .toString()
        .toLowerCase();
    if (rawPlatform.contains('5')) return 'ps5';
    if (rawPlatform.contains('4')) return 'ps4';

    final rawGuideEndpoint =
        (localGame?.guideEndpoint ?? psnGame?.guideEndpoint ?? '')
            .toString()
            .toLowerCase();
    if (rawGuideEndpoint.contains('ps5')) return 'ps5';
    return 'ps4';
  }

  int get completionPercent => psnGame?.completionPercent ?? 0;

  int get trophyTotal =>
      (psnGame?.totalBronze ?? 0) +
      (psnGame?.totalSilver ?? 0) +
      (psnGame?.totalGold ?? 0) +
      (psnGame?.totalPlatinum ?? 0);

  int get trophyEarned =>
      (psnGame?.earnedBronze ?? 0) +
      (psnGame?.earnedSilver ?? 0) +
      (psnGame?.earnedGold ?? 0) +
      (psnGame?.earnedPlatinum ?? 0);

  String get guideEndpoint =>
      localGame?.guideEndpoint ?? psnGame?.guideEndpoint ?? 'ps4/guide/';

  GameModel toGameModel() {
    if (localGame != null) {
      return GameModel(
        gameName: localGame!.gameName,
        gameImageUrl: localGame!.gameImageUrl,
        gold: localGame!.gold,
        silver: localGame!.silver,
        bronze: localGame!.bronze,
        platinum: localGame!.platinum,
        guideEndpoint: guideEndpoint,
        platform: platform,
      );
    }
    return GameModel(
      gameName: psnGame!.name,
      gameImageUrl: psnGame!.imageUrl,
      gold: '${psnGame!.totalGold}',
      silver: '${psnGame!.totalSilver}',
      bronze: '${psnGame!.totalBronze}',
      platinum: '${psnGame!.totalPlatinum}',
      guideEndpoint: guideEndpoint,
      platform: platform,
    );
  }
}
