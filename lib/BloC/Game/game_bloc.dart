import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:game_trophy_manager/Model/game.dart';
import 'package:game_trophy_manager/Utilities/game_data_manager.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc(this.gameDataManager) : super(GameListInitial());
  final GameDataManager gameDataManager;
  @override
  Stream<GameState> mapEventToState(
    GameEvent event,
  ) async* {
    if (event is GetGameList) {
      final gameList = await gameDataManager.fetchAddedGames();
      yield GameListLoaded(gameList);
    }
  }
}
