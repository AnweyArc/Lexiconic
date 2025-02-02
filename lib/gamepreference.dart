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
        return Colors.green.shade800; // Green for easy
      case 1:
        return Colors.orange.shade800; // Orange for hard
      case 2:
        return Colors.red.shade800; // Dark red for nightmare
      default:
        return Colors.green.shade800; // Default to green
    }
  }

  // Method to convert the slider value to the difficulty string
  String getDifficultyLabel(double value) {
    if (value == 0) {
      return "EASY (5 LETTERS)";
    } else if (value == 1) {
      return "HARD (6 LETTERS)";
    } else {
      return "NIGHTMARE (8 LETTERS)";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'LEXICONIC',
          style: TextStyle(
            fontFamily: 'LibreFranklin',
            fontSize: 32,
            letterSpacing: 3,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 23, 0, 31),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              getBackgroundColor(_difficultyValue).withOpacity(0.9),
              getBackgroundColor(_difficultyValue).withOpacity(0.7),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "SELECT DIFFICULTY",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontFamily: 'LibreFranklin',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 40),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        getDifficultyLabel(_difficultyValue),
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'LibreFranklin',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 20),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white70,
                          thumbColor: Colors.white,
                          overlayColor: Colors.white30,
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 12,
                          ),
                          overlayShape: RoundSliderOverlayShape(
                            overlayRadius: 20,
                          ),
                          trackHeight: 6,
                        ),
                        child: Slider(
                          value: _difficultyValue,
                          min: 0,
                          max: 2,
                          divisions: 2,
                          onChanged: (value) {
                            setState(() {
                              _difficultyValue = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                _buildStartButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
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
          padding: EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.deepPurpleAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        child: Text(
          "START GAME",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'LibreFranklin',
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
