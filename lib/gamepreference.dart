import 'package:flutter/material.dart';
import 'game.dart';

class GamePreferenceScreen extends StatefulWidget {
  @override
  _GamePreferenceScreenState createState() => _GamePreferenceScreenState();
}

class _GamePreferenceScreenState extends State<GamePreferenceScreen> {
  double _difficultyValue = 0; // Slider value (0, 1, or 2)

  // Method to get the background color based on the selected difficulty
  Color getBackgroundColor(double difficultyValue) {
    switch (difficultyValue.toInt()) {
      case 0:
        return Colors.green.shade600; // Green for easy
      case 1:
        return Colors.orange.shade600; // Orange for hard
      case 2:
        return Colors.red.shade900; // Dark red for nightmare
      default:
        return Colors
            .green
            .shade600; // Default to green if no difficulty selected
    }
  }

  // Method to convert the slider value to the difficulty string
  String getDifficultyLabel(double value) {
    if (value == 0) {
      return "Easy (5 letters)";
    } else if (value == 1) {
      return "Hard (6 letters)";
    } else {
      return "Nightmare (8 letters)";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lexiconic',
          style: TextStyle(
            fontFamily: 'LibreFranklin',
            fontSize: 32,
            letterSpacing: 3,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: getBackgroundColor(
          _difficultyValue,
        ), // Set background color based on difficulty
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Select Difficulty:",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontFamily: 'LibreFranklin',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 30),
              Text(
                getDifficultyLabel(_difficultyValue),
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'LibreFranklin',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Slider(
                value: _difficultyValue,
                min: 0,
                max: 2,
                divisions: 2,
                onChanged: (value) {
                  setState(() {
                    _difficultyValue = value;
                  });
                },
                activeColor: Colors.white,
                inactiveColor: Colors.white70,
              ),
              SizedBox(height: 40),
              _buildStartButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build the "Start Game" button with updated design
  Widget _buildStartButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () {
          String difficulty;
          if (_difficultyValue == 0) {
            difficulty = "easy";
          } else if (_difficultyValue == 1) {
            difficulty = "hard";
          } else {
            difficulty = "nightmare";
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WordleHomePage(difficulty: difficulty),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 50),
          backgroundColor: Colors.deepPurpleAccent, // Button background color
          foregroundColor: Colors.white, // Text color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Rounded corners
          ),
          elevation: 8, // Shadow effect
        ),
        child: Text(
          "Start Game",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'LibreFranklin', // Apply custom font
          ),
        ),
      ),
    );
  }
}
