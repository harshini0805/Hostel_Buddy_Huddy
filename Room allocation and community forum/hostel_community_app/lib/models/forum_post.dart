class ForumPost {
  final String id;
  final String content;
  final String category;
  final String createdAt;

  ForumPost({
    required this.id,
    required this.content,
    required this.category,
    required this.createdAt,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'category': category,
    };
  }
}