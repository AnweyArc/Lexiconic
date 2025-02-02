import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AchievementsScreen extends StatefulWidget {
  @override
  _AchievementsScreenState createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  Map<String, List<Map<String, dynamic>>> achievements = {
    "Easy": [
      {"title": "Nice Guessing!", "threshold": 1, "unlocked": false},
      {
        "title": "Woah, you're pretty good at this!",
        "threshold": 50,
        "unlocked": false,
      },
      {"title": "Lexiconic Master, huh?", "threshold": 100, "unlocked": false},
      {"title": "You're Getting There!", "threshold": 250, "unlocked": false},
      {"title": "???", "threshold": 500, "unlocked": false},
    ],
    "Normal": [
      {"title": "Nice Guessing!", "threshold": 15, "unlocked": false},
      {
        "title": "Woah, you're pretty good at this!",
        "threshold": 50,
        "unlocked": false,
      },
      {"title": "Lexiconic Master, huh?", "threshold": 100, "unlocked": false},
      {"title": "You're Getting There!", "threshold": 250, "unlocked": false},
      {"title": "???", "threshold": 500, "unlocked": false},
    ],
    "Nightmare": [
      {"title": "Nice Guessing!", "threshold": 1, "unlocked": false},
      {
        "title": "Woah, you're pretty good at this!",
        "threshold": 50,
        "unlocked": false,
      },
      {"title": "Lexiconic Master, huh?", "threshold": 100, "unlocked": false},
      {"title": "You're Getting There!", "threshold": 250, "unlocked": false},
      {"title": "???", "threshold": 500, "unlocked": false},
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      achievements.forEach((category, achievementList) {
        int guessedWords = prefs.getInt('${category}_guessedWords') ?? 0;
        for (var achievement in achievementList) {
          achievement["unlocked"] =
              prefs.getBool('${category}_${achievement["title"]}') ??
              (guessedWords >= achievement["threshold"]);
        }
      });
    });
  }

  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    achievements.forEach((category, achievementList) {
      for (var achievement in achievementList) {
        prefs.setBool(
          '${category}_${achievement["title"]}',
          achievement["unlocked"],
        );
      }
    });
  }

  void _updateAchievements(String category, int guessedWords) {
    setState(() {
      for (var achievement in achievements[category]!) {
        if (guessedWords >= achievement["threshold"] &&
            !achievement["unlocked"]) {
          achievement["unlocked"] = true;
        }
      }
      _saveAchievements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Achievements',
          style: TextStyle(
            fontFamily: 'LibreFranklin',
            fontSize: 24,
            letterSpacing: 3,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 23, 0, 31),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children:
            achievements.entries.map((entry) {
              return _buildAchievementCategory(entry.key, entry.value);
            }).toList(),
      ),
    );
  }

  Widget _buildAchievementCategory(
    String category,
    List<Map<String, dynamic>> achievementList,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          category,
          style: TextStyle(
            fontFamily: 'LibreFranklin',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        children:
            achievementList.map((achievement) {
              return ListTile(
                leading: Icon(
                  achievement["unlocked"] ? Icons.check_circle : Icons.lock,
                  color: achievement["unlocked"] ? Colors.green : Colors.grey,
                ),
                title: Text(achievement["title"]),
                subtitle: LinearProgressIndicator(
                  value: achievement["unlocked"] ? 1.0 : 0.0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                trailing: Text(
                  "${achievement["threshold"]} Guessed",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            }).toList(),
      ),
    );
  }
}
