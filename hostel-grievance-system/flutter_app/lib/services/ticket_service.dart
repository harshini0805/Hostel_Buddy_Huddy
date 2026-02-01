import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket_models.dart';

class TicketService {
  // Update this URL to your backend URL
  static const String baseUrl = 'http://10.0.2.2:8000';

  // For Android emulator, use: http://10.0.2.2:8000
  // For iOS simulator, use: http://localhost:8000
  // For real device, use your computer's IP address

  Future<TicketResponse> createTicket(CreateTicketRequest request) async {
    try {
      final url = Uri.parse('$baseUrl/tickets');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Add authentication token here when implemented
          // 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return TicketResponse.fromJson(responseData);
      } else if (response.statusCode == 422) {
        // Validation error
        final errorData = jsonDecode(response.body);
        throw Exception('Validation error: ${errorData['detail']}');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      } else {
        throw Exception('Failed to create ticket: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final url = Uri.parse('$baseUrl/health');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Health check failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Fetch active tickets for the student feed
  Future<List<TicketResponse>> fetchTicketFeed() async {
    try {
      final url = Uri.parse(TicketService.baseUrl + "/tickets/feed");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => TicketResponse.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load ticket feed');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<void> voteOnTicket(String ticketId) async {
    try {
      final url = Uri.parse('${TicketService.baseUrl}/tickets/$ticketId/vote');
      final response = await http.post(url);

      if (response.statusCode != 200) {
        throw Exception('Already voted or vote failed');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}
