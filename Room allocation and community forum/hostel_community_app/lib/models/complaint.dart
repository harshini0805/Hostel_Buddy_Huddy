class Complaint {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final int upvotes;
  final int downvotes;
  final String createdAt;

  Complaint({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.upvotes,
    required this.downvotes,
    required this.createdAt,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdBy: json['created_by'] ?? '',
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }
}