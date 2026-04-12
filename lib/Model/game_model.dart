class GameModel {
  String gameName;
  String gameImageUrl;
  String gold;
  String silver;
  String bronze;
  String platinum;
  String guideEndpoint;
  String platform;

  GameModel(
      {required this.gameName,
      required this.gameImageUrl,
      this.bronze = '',
      this.gold = '',
      this.platinum = '',
      this.silver = '',
      this.guideEndpoint = 'ps4/guide/',
      this.platform = 'ps4'});

  GameModel.fromJson(
    Map<String, dynamic> json, {
    String guideEndpoint = 'ps4/guide/',
    String platform = 'ps4',
  })  : gameName = json['game_name'] ?? '',
        gameImageUrl = json['game_image_link'] ?? '',
        gold = json['gold'] ?? '',
        silver = json['silver'] ?? '',
        bronze = json['bronze'] ?? '',
        platinum = json['platinum'] ?? '',
        guideEndpoint = guideEndpoint,
        platform = json['platform'] ?? platform;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['game_name'] = this.gameName;
    data['game_image_url'] = this.gameImageUrl;
    data['gold'] = this.gold;
    data['silver'] = this.silver;
    data['bronze'] = this.bronze;
    data['platinum'] = this.platinum;
    data['platform'] = this.platform;
    return data;
  }
}
