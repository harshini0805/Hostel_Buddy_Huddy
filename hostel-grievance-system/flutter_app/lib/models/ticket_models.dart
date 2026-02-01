enum IssueCategory {
  electrical,
  plumbing,
  civil,
  internet,
  safety,
  other,
}

enum ImpactRadius {
  room,
  floor,
  hostel,
}

enum UrgencyLevel {
  low,
  medium,
  high,
}

enum TicketStatus {
  submitted,
  assigned,
  inProgress,
  resolved,
  closed,
}

class Student {
  final String id;
  final String name;
  final String department;
  final String hostel;
  final String block;
  final String room;

  Student({
    required this.id,
    required this.name,
    required this.department,
    required this.hostel,
    required this.block,
    required this.room,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      name: json['name'] as String,
      department: json['department'] as String,
      hostel: json['hostel'] as String,
      block: json['block'] as String,
      room: json['room'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'hostel': hostel,
      'block': block,
      'room': room,
    };
  }
}

class CreateTicketRequest {
  final IssueCategory category;
  final ImpactRadius impactRadius;
  final UrgencyLevel urgency;
  final String description;
  final List<String> mediaUrls;

  CreateTicketRequest({
    required this.category,
    required this.impactRadius,
    required this.urgency,
    required this.description,
    this.mediaUrls = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category.name,
      'impact_radius': _convertImpactRadius(impactRadius),
      'urgency': urgency.name,
      'description': description,
      'media_urls': mediaUrls,
    };
  }

  String _convertImpactRadius(ImpactRadius radius) {
    switch (radius) {
      case ImpactRadius.room:
        return 'room';
      case ImpactRadius.floor:
        return 'floor';
      case ImpactRadius.hostel:
        return 'hostel';
    }
  }
}

class StudentInfo {
  final String id;
  final String name;
  final String department;

  StudentInfo({
    required this.id,
    required this.name,
    required this.department,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      department: json['department'] as String,
    );
  }
}

class LocationInfo {
  final String hostel;
  final String block;
  final int floor;
  final String room;

  LocationInfo({
    required this.hostel,
    required this.block,
    required this.floor,
    required this.room,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      hostel: json['hostel'] as String,
      block: json['block'] as String,
      floor: json['floor'] as int,
      room: json['room'] as String,
    );
  }
}

class VotesInfo {
  final int count;
  final List<String> voters;

  VotesInfo({
    required this.count,
    required this.voters,
  });

  factory VotesInfo.fromJson(Map<String, dynamic> json) {
    return VotesInfo(
      count: json['count'] as int,
      voters: List<String>.from(json['voters'] as List),
    );
  }
}

class TicketResponse {
  final String id;
  final StudentInfo student;
  final LocationInfo location;
  final String category;
  final String impactRadius;
  final String urgency;
  final String description;
  final List<String> mediaUrls;
  final String assignedVendor;
  final String status;
  final int priorityScore;
  final VotesInfo votes;
  final DateTime createdAt;
  final DateTime updatedAt;

  TicketResponse({
    required this.id,
    required this.student,
    required this.location,
    required this.category,
    required this.impactRadius,
    required this.urgency,
    required this.description,
    required this.mediaUrls,
    required this.assignedVendor,
    required this.status,
    required this.priorityScore,
    required this.votes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TicketResponse.fromJson(Map<String, dynamic> json) {
    return TicketResponse(
      id: json['id'] as String,
      student: StudentInfo.fromJson(json['student'] as Map<String, dynamic>),
      location: LocationInfo.fromJson(json['location'] as Map<String, dynamic>),
      category: json['category'] as String,
      impactRadius: json['impact_radius'] as String,
      urgency: json['urgency'] as String,
      description: json['description'] as String,
      mediaUrls: List<String>.from(json['media_urls'] as List),
      assignedVendor: json['assigned_vendor'] as String,
      status: json['status'] as String,
      priorityScore: json['priority_score'] as int,
      votes: VotesInfo.fromJson(json['votes'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
