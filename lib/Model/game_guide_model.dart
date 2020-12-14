class GuideModel {
  String trophyName;
  String trophyImage;
  String trophyType;
  String trophyDescription;
  String trophyGuide;
  GuideModel({
    this.trophyDescription,
    this.trophyGuide,
    this.trophyImage,
    this.trophyName,
    this.trophyType,
  });

  GuideModel.fromJson(Map<String, dynamic> json) {
    trophyType = json['trophy_type'];
    trophyName = json['trophy_name'];
    trophyImage = json['trophy_image'];
    trophyDescription = json['trophy_description'];
    trophyGuide = json['trophy_guide'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['trophy_type'] = this.trophyType;
    data['trophy_name'] = this.trophyName;
    data['trophy_image'] = this.trophyImage;
    data['trophy_description'] = this.trophyDescription;
    data['trophy_guide'] = this.trophyGuide;
    return data;
  }
}
