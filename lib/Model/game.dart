import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class Game extends Equatable {
  final String gameName;
  final String gameImageLink;
  final double gameCompletionPercentage;
  Game(
      {@required this.gameName,
      @required this.gameCompletionPercentage,
      @required this.gameImageLink});

  @override
  // TODO: implement props
  List<Object> get props => [gameName, gameImageLink, gameCompletionPercentage];
}
