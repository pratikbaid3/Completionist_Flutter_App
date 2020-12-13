class GameModel {
  String gameName;
  String gameImageUrl;

  GameModel({
    this.gameName,
    this.gameImageUrl,
  });

  GameModel.fromJson(Map<String, dynamic> json) {
    gameName = json['game_name'];
    gameImageUrl = json['game_image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['game_image_url'] = this.gameName;
    data['game_image_url'] = this.gameImageUrl;
    return data;
  }
}
