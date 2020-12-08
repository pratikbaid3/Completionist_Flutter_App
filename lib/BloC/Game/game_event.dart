part of 'game_bloc.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();
}

class GetGameList extends GameEvent {
  @override
  // TODO: implement props
  List<Object> get props => [];
}
