class GameModel {
  String gameName;
  String gameImageUrl;
  String gold;
  String silver;
  String bronze;
  String platinum;

  GameModel(
      {this.gameName,
      this.gameImageUrl,
      this.bronze,
      this.gold,
      this.platinum,
      this.silver});

  GameModel.fromJson(Map<String, dynamic> json) {
    gameName = json['game_name'];
    gameImageUrl = json['game_image_link'];
    gold = json['gold'];
    silver = json['silver'];
    bronze = json['bronze'];
    platinum = json['platinum'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['game_image_url'] = this.gameName;
    data['game_image_url'] = this.gameImageUrl;
    return data;
  }
}
