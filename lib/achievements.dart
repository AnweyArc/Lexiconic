import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data_info.dart';

class AchievementsScreen extends StatefulWidget {
  @override
  _AchievementsScreenState createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  Map<String, List<Map<String, dynamic>>> achievements = {
    "Easy": [
      {"title": "Nice Guessing!", "threshold": 5, "unlocked": false},
      {
        "title": "Woah, you're pretty good at this!",
        "threshold": 50,
        "unlocked": false,
      },
      {"title": "Lexiconic Master, huh?", "threshold": 100, "unlocked": false},
      {"title": "You're Getting There!", "threshold": 250, "unlocked": false},
      {"title": "???", "threshold": 500, "unlocked": false},
    ],
    "Hard": [
      {"title": "Nice Guessing!", "threshold": 5, "unlocked": false},
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
      {"title": "Nice Guessing!", "threshold": 5, "unlocked": false},
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
      case 'Hard':
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
    _initializeAchievements();
  }

  Future<void> _initializeAchievements() async {
    await loadGuessedWords(); // Ensure guessed words are loaded
    await _loadAchievementStates();
  }

  Future<void> _loadAchievementStates() async {
    final prefs = await SharedPreferences.getInstance();

    // Process each category sequentially
    for (var category in achievements.keys.toList()) {
      final achievementList = achievements[category]!;
      final guessedWordsCount = _getGuessedCountForCategory(category);

      for (var achievement in achievementList) {
        final key = 'achv_${category}_${achievement["title"]}';
        final previouslyUnlocked = prefs.getBool(key) ?? false;
        final thresholdReached = guessedWordsCount >= achievement["threshold"];

        achievement["unlocked"] = previouslyUnlocked || thresholdReached;

        if (!previouslyUnlocked && thresholdReached) {
          await prefs.setBool(key, true);
        }
      }
    }

    if (mounted) setState(() {});
  }

  int _getGuessedCountForCategory(String category) {
    switch (category) {
      case 'Easy':
        return easyGuessedWords.length;
      case 'Hard':
        return hardGuessedWords.length;
      case 'Nightmare':
        return nightmareGuessedWords.length;
      default:
        return 0;
    }
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
              achievements.entries
                  .map(
                    (entry) =>
                        _buildAchievementCategory(entry.key, entry.value),
                  )
                  .toList(),
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
              achievementList
                  .map(
                    (achievement) =>
                        _buildAchievementItem(category, achievement),
                  )
                  .toList(),
        ),
      ),
    );
  }

  Widget _buildAchievementItem(
    String category,
    Map<String, dynamic> achievement,
  ) {
    final currentCount = _getGuessedCountForCategory(category);
    final progress = currentCount / achievement["threshold"];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.grey[900]!.withOpacity(0.6),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                  value:
                      achievement["unlocked"] ? 1.0 : progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getDifficultyColor(category),
                  ),
                  minHeight: 8,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "${currentCount.clamp(0, achievement["threshold"])}/${achievement["threshold"]} Guessed",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'LibreFranklin',
                ),
              ),
              if (achievement["unlocked"])
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    "Achievement Unlocked!",
                    style: TextStyle(
                      color: Colors.greenAccent.shade400,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'LibreFranklin',
                    ),
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
  }
}
