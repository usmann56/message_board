import 'package:flutter/material.dart';
import '../components/app_drawer.dart';

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
      appBar: AppBar(title: const Text('Select A Room'), centerTitle: false),

      drawer: AppDrawer(),

      body: ListView(
        padding: EdgeInsets.zero,
        children: const [
          RoomSection(
            title: 'Games',
            backgroundColor: Color(0xFFFF5733),
            assetPath: 'assets/gammer.avif',
          ),
          RoomSection(
            title: 'Business',
            backgroundColor: Color(0xFF6A994E),
            assetPath: 'assets/business.avif',
          ),
          RoomSection(
            title: 'Public Health',
            backgroundColor: Color(0xFF4C8CD2),
            assetPath: 'assets/public_health.jpg',
          ),
          RoomSection(
            title: 'Study',
            backgroundColor: Color(0xFF7B3F9F),
            assetPath: 'assets/study.jpeg',
          ),
        ],
      ),
    );
  }
}
