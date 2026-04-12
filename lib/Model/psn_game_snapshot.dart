import 'package:game_trophy_manager/Model/game_model.dart';
import 'package:game_trophy_manager/Utilities/api.dart';

class PsnGameSnapshot {
  final String titleId;
  final String name;
  final String platform;
  final String imageUrl;
  final int earnedBronze;
  final int earnedSilver;
  final int earnedGold;
  final int earnedPlatinum;
  final int totalBronze;
  final int totalSilver;
  final int totalGold;
  final int totalPlatinum;
  final int completionPercent;
  final String lastPlayedAt;

  const PsnGameSnapshot({
    this.titleId = '',
    this.name = '',
    this.platform = 'ps4',
    this.imageUrl = '',
    this.earnedBronze = 0,
    this.earnedSilver = 0,
    this.earnedGold = 0,
    this.earnedPlatinum = 0,
    this.totalBronze = 0,
    this.totalSilver = 0,
    this.totalGold = 0,
    this.totalPlatinum = 0,
    this.completionPercent = 0,
    this.lastPlayedAt = '',
  });

  factory PsnGameSnapshot.fromJson(Map<String, dynamic> json) {
    final earned =
        (json['earned_counts'] as Map?)?.cast<String, dynamic>() ?? {};
    final total = (json['total_counts'] as Map?)?.cast<String, dynamic>() ?? {};
    return PsnGameSnapshot(
      titleId: json['title_id'] ?? '',
      name: json['name'] ?? '',
      platform: (json['platform'] ?? 'ps4').toString().toLowerCase(),
      imageUrl: json['image_url'] ?? '',
      earnedBronze: _asInt(earned['bronze']),
      earnedSilver: _asInt(earned['silver']),
      earnedGold: _asInt(earned['gold']),
      earnedPlatinum: _asInt(earned['platinum']),
      totalBronze: _asInt(total['bronze']),
      totalSilver: _asInt(total['silver']),
      totalGold: _asInt(total['gold']),
      totalPlatinum: _asInt(total['platinum']),
      completionPercent: _asInt(json['completion_percent']),
      lastPlayedAt: json['last_played_at'] ?? '',
    );
  }

  factory PsnGameSnapshot.fromDb(Map<String, dynamic> row) {
    return PsnGameSnapshot(
      titleId: row['TitleId'] ?? '',
      name: row['GameName'] ?? '',
      platform: (row['Platform'] ?? 'ps4').toString().toLowerCase(),
      imageUrl: row['GameImgUrl'] ?? '',
      earnedBronze: _asInt(row['EarnedBronze']),
      earnedSilver: _asInt(row['EarnedSilver']),
      earnedGold: _asInt(row['EarnedGold']),
      earnedPlatinum: _asInt(row['EarnedPlatinum']),
      totalBronze: _asInt(row['TotalBronze']),
      totalSilver: _asInt(row['TotalSilver']),
      totalGold: _asInt(row['TotalGold']),
      totalPlatinum: _asInt(row['TotalPlatinum']),
      completionPercent: _asInt(row['CompletionPercent']),
      lastPlayedAt: row['LastPlayedAt'] ?? '',
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'TitleId': titleId,
      'GameName': name,
      'Platform': platform,
      'GameImgUrl': imageUrl,
      'EarnedBronze': earnedBronze,
      'EarnedSilver': earnedSilver,
      'EarnedGold': earnedGold,
      'EarnedPlatinum': earnedPlatinum,
      'TotalBronze': totalBronze,
      'TotalSilver': totalSilver,
      'TotalGold': totalGold,
      'TotalPlatinum': totalPlatinum,
      'CompletionPercent': completionPercent,
      'LastPlayedAt': lastPlayedAt,
    };
  }

  String get guideEndpoint => platform == 'ps5' ? ps5GuideUrl : ps4GuideUrl;

  GameModel toGameModel() {
    return GameModel(
      gameName: name,
      gameImageUrl: imageUrl,
      gold: '$totalGold',
      silver: '$totalSilver',
      bronze: '$totalBronze',
      platinum: '$totalPlatinum',
      guideEndpoint: guideEndpoint,
      platform: platform,
    );
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}
