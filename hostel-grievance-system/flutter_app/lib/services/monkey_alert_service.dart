import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class MonkeyAlertService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> sendMonkeyAlert(BuildContext context) async {
    final url = Uri.parse("http://10.0.2.2:8000/alerts/monkey");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"notes": "Monkey spotted"}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data["play_sound"] == true) {
          await _player.play(
            AssetSource("sounds/alert.mp3"),
            volume: 1.0,
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🚨 Monkey alert sent! Stay cautious"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        throw Exception("Failed to send alert");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to send monkey alert"),
        ),
      );
    }
  }
}
