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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.green.shade800;
      case 'Normal':
        return Colors.orange.shade800;
      case 'Nightmare':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Achievements',
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
              Color.fromARGB(255, 23, 0, 31),
              Color.fromARGB(255, 54, 0, 73),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children:
              achievements.entries.map((entry) {
                return _buildAchievementCategory(entry.key, entry.value);
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildAchievementCategory(
    String category,
    List<Map<String, dynamic>> achievementList,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: _getDifficultyColor(category).withOpacity(0.9),
        child: ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: Colors.white,
          textColor: Colors.white,
          collapsedTextColor: Colors.white,
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              category.toUpperCase(),
              style: TextStyle(
                fontFamily: 'LibreFranklin',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          children:
              achievementList.map((achievement) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.grey[900]!.withOpacity(0.6),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      leading: Icon(
                        achievement["unlocked"]
                            ? Icons.check_circle
                            : Icons.lock_outline_rounded,
                        color:
                            achievement["unlocked"]
                                ? Colors.greenAccent.shade400
                                : Colors.grey.shade400,
                        size: 32,
                      ),
                      title: Text(
                        achievement["title"],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'LibreFranklin',
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: achievement["unlocked"] ? 1.0 : 0.0,
                              backgroundColor: Colors.grey[800],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getDifficultyColor(category),
                              ),
                              minHeight: 8,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "${achievement["threshold"]} Guessed",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontFamily: 'LibreFranklin',
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        Icons.emoji_events_rounded,
                        color:
                            achievement["unlocked"]
                                ? Colors.amber.shade300
                                : Colors.grey.shade600,
                        size: 32,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
