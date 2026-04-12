class PsnProfileCache {
  final String accountId;
  final String onlineId;
  final String avatarUrl;

  const PsnProfileCache({
    this.accountId = '',
    this.onlineId = '',
    this.avatarUrl = '',
  });

  factory PsnProfileCache.fromJson(Map<String, dynamic> json) {
    return PsnProfileCache(
      accountId: json['account_id'] ?? '',
      onlineId: json['online_id'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId,
      'online_id': onlineId,
      'avatar_url': avatarUrl,
    };
  }
}
