import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<String>> fetchWords(String difficulty) async {
  int length;
  if (difficulty == "easy") {
    length = 5;
  } else if (difficulty == "hard") {
    length = 6;
  } else {
    length = 8; // Nightmare mode
  }

  final response = await http.get(
    Uri.parse(
      'https://random-word-api.herokuapp.com/word?length=$length&number=50',
    ),
  );

  if (response.statusCode == 200) {
    List<dynamic> words = json.decode(response.body);
    return words.map((word) => word.toString().toUpperCase()).toList();
  } else {
    throw Exception('Failed to load words');
  }
}
