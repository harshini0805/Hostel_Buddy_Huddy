import 'package:flutter/material.dart';
import 'screens/community_hub_screen.dart';

void main() {
  runApp(const HostelCommunityApp());
}

class HostelCommunityApp extends StatelessWidget {
  const HostelCommunityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hostel Community',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const CommunityHubScreen(),
    );
  }
}