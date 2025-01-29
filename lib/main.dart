import 'package:flutter/material.dart';
import 'gamepreference.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(), // Set HomeScreen as the initial screen
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, double> _scaleMap = {
    "Play": 1.0,
    "Achievements": 1.0,
    "Settings": 1.0,
    "Dictionary": 1.0,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lexiconic',
          style: TextStyle(
            fontFamily: 'LibreFranklin', // Apply custom font to the title
            fontSize: 32,
            letterSpacing: 3,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Container(
        decoration: BoxDecoration(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMenuButton(
                context,
                "Play",
                Icons.play_arrow,
                Colors.green, // Play button color
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GamePreferenceScreen(),
                  ),
                ),
              ),
              _buildMenuButton(
                context,
                "Achievements",
                Icons.emoji_events,
                Colors.orange, // Achievements button color
                () {
                  // Implement Achievements screen navigation
                },
              ),
              _buildMenuButton(
                context,
                "Settings",
                Icons.settings,
                Colors.blue, // Settings button color
                () {
                  // Implement Settings screen navigation
                },
              ),
              _buildMenuButton(
                context,
                "Dictionary",
                Icons.book,
                Colors.purple, // Dictionary button color
                () {
                  // Implement Dictionary screen navigation
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String text,
    IconData icon,
    Color buttonColor,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
      child: MouseRegion(
        onEnter: (_) => _onHover(true, text), // On hover, scale up
        onExit: (_) => _onHover(false, text), // On exit, reset scale
        child: AnimatedScale(
          scale: _scaleMap[text]!, // Use the scale from the map
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: InkWell(
            onTap: onPressed,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
              decoration: BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: buttonColor.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 28, color: Colors.white),
                  SizedBox(width: 16),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'LibreFranklin',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Method to update scale for a specific button when hovered
  void _onHover(bool isHovered, String buttonText) {
    setState(() {
      if (isHovered) {
        _scaleMap[buttonText] = 1.1; // Scale up the hovered button
      } else {
        _scaleMap[buttonText] = 1.0; // Reset scale for the non-hovered button
      }
    });
  }
}
