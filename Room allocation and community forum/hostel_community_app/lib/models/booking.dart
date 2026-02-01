class Booking {
  final String roomId;
  final String onDate;
  final String startTime;
  final String endTime;
  final String purpose;
  final String bookedBy;

  Booking({
    required this.roomId,
    required this.onDate,
    required this.startTime,
    required this.endTime,
    required this.purpose,
    required this.bookedBy,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      roomId: json['room_id'] ?? '',
      onDate: json['on_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      purpose: json['purpose'] ?? '',
      bookedBy: json['booked_by'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'on_date': onDate,
      'start_time': startTime,
      'end_time': endTime,
      'purpose': purpose,
    };
  }
}