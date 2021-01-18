class GameModel {
  String gameName;
  String gameImageUrl;
  String gold;
  String silver;
  String bronze;
  String platinum;
  String videoLink;

  GameModel(
      {this.gameName,
      this.gameImageUrl,
      this.bronze,
      this.gold,
      this.platinum,
      this.silver,
      this.videoLink});

  GameModel.fromJson(Map<String, dynamic> json) {
    gameName = json['game_name'];
    gameImageUrl = json['game_image_url'];
    gold = json['gold'];
    silver = json['silver'];
    bronze = json['bronze'];
    platinum = json['platinum'];
    videoLink = json['trophy_youtube_link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['game_image_url'] = this.gameName;
    data['game_image_url'] = this.gameImageUrl;
    return data;
  }
}
