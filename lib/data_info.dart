// data_info.dart
import 'package:shared_preferences/shared_preferences.dart';

List<String> successfullyGuessedWords = [];

// Get filtered lists by difficulty using word length
List<String> get easyGuessedWords =>
    successfullyGuessedWords.where((word) => word.length == 5).toList();

List<String> get hardGuessedWords =>
    successfullyGuessedWords.where((word) => word.length == 6).toList();

List<String> get nightmareGuessedWords =>
    successfullyGuessedWords.where((word) => word.length == 8).toList();

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