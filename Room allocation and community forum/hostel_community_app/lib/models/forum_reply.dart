class ForumReply {
  final String id;
  final String postId;
  final String content;
  final String createdAt;

  ForumReply({
    required this.id,
    required this.postId,
    required this.content,
    required this.createdAt,
  });

  factory ForumReply.fromJson(Map<String, dynamic> json) {
    return ForumReply(
      id: json['id'] ?? '',
      postId: json['post_id'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'post_id': postId,
      'content': content,
    };
  }
}