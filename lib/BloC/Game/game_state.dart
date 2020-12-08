part of 'game_bloc.dart';

abstract class GameState extends Equatable {
  const GameState();
}

class GameListInitial extends GameState {
  const GameListInitial();
  @override
  List<Object> get props => [];
}

class GameListLoaded extends GameState {
  final List<Game> gameList;
  const GameListLoaded(this.gameList);
  @override
  List<Object> get props => [gameList];
}
