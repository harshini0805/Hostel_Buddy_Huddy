class Sharing {
  final String id;
  final String title;
  final String description;
  final String type;
  final String postedBy;
  final int upvotes;
  final int downvotes;
  final int replyCount;
  final String createdAt;

  Sharing({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.postedBy,
    required this.upvotes,
    required this.downvotes,
    required this.replyCount,
    required this.createdAt,
  });

  factory Sharing.fromJson(Map<String, dynamic> json) {
    return Sharing(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      postedBy: json['posted_by'] ?? '',
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      replyCount: json['reply_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type,
    };
  }
}