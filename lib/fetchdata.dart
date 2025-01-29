import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<String>> fetchWords(String difficulty) async {
  int length =
      (difficulty == "easy")
          ? 5
          : (difficulty == "hard")
          ? 6
          : 8;

  try {
    final response = await http
        .get(
          Uri.parse(
            'https://random-word-api.herokuapp.com/word?length=$length&number=50',
          ),
        )
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Request timed out');
          },
        );

    if (response.statusCode == 200) {
      List<dynamic> words = json.decode(response.body);

      if (words.isEmpty) {
        throw Exception("No words returned from the API");
      }

      return words.map((word) => word.toString().toUpperCase()).toList();
    } else {
      throw Exception('Failed to load words');
    }
  } catch (e) {
    print('Error fetching words: $e');
    return _backupWords(length);
  }
}

List<String> _backupWords(int length) {
  // Sample fallback words categorized by length
  Map<int, List<String>> wordMap = {
    5: ["APPLE", "TABLE", "CHAIR", "HOUSE", "GRAPE"],
    6: ["PLANET", "MARKET", "PENCIL", "KITTEN", "CANDLE"],
    8: ["SUNSHINE", "NOTEBOOK", "ELEPHANT", "MANDARIN", "HOSPITAL"],
  };

  return wordMap[length] ?? [];
}
