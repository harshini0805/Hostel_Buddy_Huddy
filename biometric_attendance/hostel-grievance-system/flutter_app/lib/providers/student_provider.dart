import 'package:flutter/foundation.dart';
import '../models/ticket_models.dart';

class StudentProvider with ChangeNotifier {
  Student? _student;

  Student? get student => _student;

  // Mock login - Replace with actual authentication
  void setStudent(Student student) {
    _student = student;
    notifyListeners();
  }

  // Load mock student data (for Phase 1)
  void loadMockStudent() {
    _student = Student(
      id: 'STU2024001',
      name: 'Rahul Kumar',
      department: 'Computer Science',
      hostel: 'H1',
      block: 'B',
      room: '312',
    );
    notifyListeners();
  }

  void logout() {
    _student = null;
    notifyListeners();
  }

  bool get isLoggedIn => _student != null;
}
