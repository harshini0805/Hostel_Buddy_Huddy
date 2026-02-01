// lib/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Change this to your backend URL
  static const String baseUrl = "http://127.0.0.1:8000";
  // For Android emulator use: http://10.0.2.2:8000
  // For physical device use your computer's IP: http://192.168.x.x:8000

  // Submit room allocation form
  static Future<Map<String, dynamic>> submitForm({
    required String studentId,
    required String name,
    required int year,
    required double attendancePercentage,
    required double homeLat,
    required double homeLon,
    required List<String> preferences,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/submit-form'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'student_id': studentId,
          'name': name,
          'year': year,
          'attendance_percentage': attendancePercentage,
          'home_lat': homeLat,
          'home_lon': homeLon,
          'preferences': preferences,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to submit form: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error submitting form: $e');
    }
  }

  // Get allocation for a student
  static Future<Map<String, dynamic>?> getAllocation(String studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/allocation/$studentId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data == null) {
          return null;
        }
        return data;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to get allocation: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting allocation: $e');
    }
  }

  // Run allocation algorithm (Admin)
  static Future<Map<String, dynamic>> runAllocation() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/run-allocation'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to run allocation: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error running allocation: $e');
    }
  }

  // Get all allocations (Admin)
  static Future<List<Map<String, dynamic>>> getAllAllocations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/allocations'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get allocations: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting allocations: $e');
    }
  }

  // Get all submitted forms (Admin)
  static Future<List<Map<String, dynamic>>> getAllForms() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/forms'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get forms: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting forms: $e');
    }
  }

  // Get allocation statistics (Admin)
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get stats: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting stats: $e');
    }
  }
}