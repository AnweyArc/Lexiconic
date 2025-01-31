// data_info.dart
import 'package:shared_preferences/shared_preferences.dart';

List<String> successfullyGuessedWords = [];

// Save the list to SharedPreferences
Future<void> saveGuessedWords() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('guessedWords', successfullyGuessedWords);
}

// Load the list from SharedPreferences
Future<void> loadGuessedWords() async {
  final prefs = await SharedPreferences.getInstance();
  successfullyGuessedWords = prefs.getStringList('guessedWords') ?? [];
}
