import 'package:flutter/material.dart';

class RoomSection extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final String assetPath;
  final Alignment titleAlignment;

  const RoomSection({
    required this.title,
    required this.backgroundColor,
    required this.assetPath,
    this.titleAlignment = Alignment.centerLeft,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const sectionHeight = 300.0;

    return Container(
      height: sectionHeight,
      color: backgroundColor,
      child: Stack(
        children: <Widget>[
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: screenWidth * 0.7,
              child: Image.asset(assetPath, fit: BoxFit.cover),
            ),
          ),

          Positioned(
            top: 50,
            left: 20,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MainRoomScreen extends StatelessWidget {
  const MainRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select A Room'),
        centerTitle: false,
        actions: const [Icon(Icons.menu), SizedBox(width: 16)],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // --- Games Section (Red/Orange) ---
          RoomSection(
            title: 'Games',
            backgroundColor: const Color(0xFFFF5733),
            assetPath: 'assets/gammer.avif',
          ),

          // --- Business Section (Teal/Green) ---
          RoomSection(
            title: 'Business',
            backgroundColor: const Color(0xFF6A994E),
            assetPath: 'assets/business.avif',
          ),

          // --- Public Health Section (Blue/Purple) ---
          RoomSection(
            title: 'Public Health',
            backgroundColor: const Color(0xFF4C8CD2),
            assetPath: 'assets/public_health.jpg',
          ),

          // --- Study Section (Purple) ---
          RoomSection(
            title: 'Study',
            backgroundColor: const Color(0xFF7B3F9F),
            assetPath: 'assets/study.jpeg',
          ),
        ],
      ),
    );
  }
}
