class SharingReply {
  final String message;
  final String userId;
  final String createdAt;

  SharingReply({
    required this.message,
    required this.userId,
    required this.createdAt,
  });

  factory SharingReply.fromJson(Map<String, dynamic> json) {
    return SharingReply(
      message: json['message'] ?? '',
      userId: json['user_id'] ?? 'Anonymous',
      createdAt: json['created_at'] ?? '',
    );
  }
}