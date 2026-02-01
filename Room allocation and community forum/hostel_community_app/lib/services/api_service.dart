import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/forum_post.dart';
import '../models/forum_reply.dart';
import '../models/complaint.dart';
import '../models/sharing.dart';
import '../models/booking.dart';

class ApiService {
  // ✅ For Chrome/Web - use localhost
  static const String baseUrl = 'http://localhost:8000';
  
  // If backend is on different machine, use that machine's IP:
  // static const String baseUrl = 'http://192.168.1.100:8000';

  // ===================== FORUM =====================

  static Future<List<ForumPost>> getForumPosts() async {
    try {
      print('🔍 Fetching forum posts from: $baseUrl/forum/posts');
      final response = await http.get(Uri.parse('$baseUrl/forum/posts'));
      
      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ Successfully parsed ${data.length} posts');
        return data.map((json) => ForumPost.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load forum posts: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching forum posts: $e');
      throw Exception('Error fetching forum posts: $e');
    }
  }

  static Future<void> createForumPost(String content, String category) async {
    try {
      print('📤 Creating forum post...');
      print('   Content: $content');
      print('   Category: $category');
      
      final response = await http.post(
        Uri.parse('$baseUrl/forum/post'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'content': content,
          'category': category,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to create post: ${response.statusCode}');
      }
      print('✅ Post created successfully');
    } catch (e) {
      print('❌ Error creating forum post: $e');
      throw Exception('Error creating forum post: $e');
    }
  }

  static Future<List<ForumReply>> getReplies(String postId) async {
    try {
      print('🔍 Fetching replies for post: $postId');
      final response = await http.get(
        Uri.parse('$baseUrl/forum/replies/$postId'),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ Successfully parsed ${data.length} replies');
        return data.map((json) => ForumReply.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load replies: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching replies: $e');
      throw Exception('Error fetching replies: $e');
    }
  }

  static Future<void> addReply(String postId, String content) async {
    try {
      print('📤 Adding reply to post: $postId');
      print('   Content: $content');
      
      final response = await http.post(
        Uri.parse('$baseUrl/forum/reply'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'post_id': postId,
          'content': content,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to add reply: ${response.statusCode}');
      }
      print('✅ Reply added successfully');
    } catch (e) {
      print('❌ Error adding reply: $e');
      throw Exception('Error adding reply: $e');
    }
  }

  // ===================== COMPLAINTS =====================

  static Future<List<Complaint>> getComplaints() async {
    try {
      print('🔍 Fetching complaints from: $baseUrl/complaints/');
      final response = await http.get(Uri.parse('$baseUrl/complaints/'));

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ Successfully parsed ${data.length} complaints');
        return data.map((json) => Complaint.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load complaints: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching complaints: $e');
      throw Exception('Error fetching complaints: $e');
    }
  }

  static Future<void> createComplaint(String title, String description) async {
    try {
      print('📤 Creating complaint...');
      print('   Title: $title');
      print('   Description: $description');
      
      final response = await http.post(
        Uri.parse('$baseUrl/complaints/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'description': description,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to create complaint: ${response.statusCode}');
      }
      print('✅ Complaint created successfully');
    } catch (e) {
      print('❌ Error creating complaint: $e');
      throw Exception('Error creating complaint: $e');
    }
  }

  // ===================== SHARING =====================

  static Future<List<Sharing>> getSharing() async {
    try {
      print('🔍 Fetching sharing items from: $baseUrl/sharing/');
      final response = await http.get(Uri.parse('$baseUrl/sharing/'));

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ Successfully parsed ${data.length} sharing items');
        return data.map((json) => Sharing.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load sharing items: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching sharing items: $e');
      throw Exception('Error fetching sharing items: $e');
    }
  }

  static Future<void> createSharing(
      String title, String description, String type) async {
    try {
      print('📤 Creating sharing request...');
      print('   Title: $title');
      print('   Description: $description');
      print('   Type: $type');
      
      final response = await http.post(
        Uri.parse('$baseUrl/sharing/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'description': description,
          'type': type,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to create sharing: ${response.statusCode}');
      }
      print('✅ Sharing request created successfully');
    } catch (e) {
      print('❌ Error creating sharing: $e');
      throw Exception('Error creating sharing: $e');
    }
  }

  // ===================== BOOKINGS =====================

  static Future<List<Booking>> getBookings() async {
    try {
      print('🔍 Fetching bookings from: $baseUrl/bookings/');
      final response = await http.get(Uri.parse('$baseUrl/bookings/'));

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ Successfully parsed ${data.length} bookings');
        return data.map((json) => Booking.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching bookings: $e');
      throw Exception('Error fetching bookings: $e');
    }
  }

  static Future<void> createBooking({
    required String roomId,
    required String onDate,
    required String startTime,
    required String endTime,
    required String purpose,
  }) async {
    try {
      print('📤 Creating booking...');
      print('   Room: $roomId');
      print('   Date: $onDate');
      print('   Time: $startTime - $endTime');
      print('   Purpose: $purpose');
      
      final response = await http.post(
        Uri.parse('$baseUrl/bookings/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'room_id': roomId,
          'on_date': onDate,
          'start_time': startTime,
          'end_time': endTime,
          'purpose': purpose,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');
      
      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to create booking');
      }
      print('✅ Booking created successfully');
    } catch (e) {
      print('❌ Error creating booking: $e');
      throw Exception('Error creating booking: $e');
    }
  }

  // ===================== VOTING =====================

  static Future<void> voteComplaint(String complaintId, String voteType) async {
    try {
      print('📤 Voting on complaint: $complaintId ($voteType)');
      
      final response = await http.post(
        Uri.parse('$baseUrl/complaints/$complaintId/vote'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'vote_type': voteType}),
      );

      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to vote: ${response.statusCode}');
      }
      print('✅ Vote recorded successfully');
    } catch (e) {
      print('❌ Error voting: $e');
      throw Exception('Error voting: $e');
    }
  }

  static Future<void> voteSharing(String sharingId, String voteType) async {
    try {
      print('📤 Voting on sharing: $sharingId ($voteType)');
      
      final response = await http.post(
        Uri.parse('$baseUrl/sharing/$sharingId/vote'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'vote_type': voteType}),
      );

      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to vote: ${response.statusCode}');
      }
      print('✅ Vote recorded successfully');
    } catch (e) {
      print('❌ Error voting: $e');
      throw Exception('Error voting: $e');
    }
  }

  // ===================== SHARING REPLIES =====================

  static Future<List<dynamic>> getSharingReplies(String sharingId) async {
    try {
      print('🔍 Fetching replies for sharing: $sharingId');
      final response = await http.get(
        Uri.parse('$baseUrl/sharing/$sharingId/replies'),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ Successfully parsed ${data.length} replies');
        return data;
      } else {
        throw Exception('Failed to load replies: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching replies: $e');
      throw Exception('Error fetching replies: $e');
    }
  }

  static Future<void> addSharingReply(String sharingId, String content) async {
    try {
      print('📤 Adding reply to sharing: $sharingId');
      print('   Content: $content');
      
      final response = await http.post(
        Uri.parse('$baseUrl/sharing/$sharingId/reply'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': content,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to add reply: ${response.statusCode}');
      }
      print('✅ Reply added successfully');
    } catch (e) {
      print('❌ Error adding reply: $e');
      throw Exception('Error adding reply: $e');
    }
  }
}