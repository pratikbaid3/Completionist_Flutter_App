class GameModel {
  String gameName;
  String gameImageUrl;
  String gold;
  String silver;
  String bronze;
  String platinum;
  String guideEndpoint;

  GameModel(
      {required this.gameName,
      required this.gameImageUrl,
      this.bronze = '',
      this.gold = '',
      this.platinum = '',
      this.silver = '',
      this.guideEndpoint = 'ps4/guide/'});

  GameModel.fromJson(Map<String, dynamic> json, {String guideEndpoint = 'ps4/guide/'})
      : gameName = json['game_name'] ?? '',
        gameImageUrl = json['game_image_link'] ?? '',
        gold = json['gold'] ?? '',
        silver = json['silver'] ?? '',
        bronze = json['bronze'] ?? '',
        platinum = json['platinum'] ?? '',
        guideEndpoint = guideEndpoint;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['game_image_url'] = this.gameName;
    data['game_image_url'] = this.gameImageUrl;
    return data;
  }
}
