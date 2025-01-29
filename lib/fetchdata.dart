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
    5: [
      "APPLE",
      "TABLE",
      "CHAIR",
      "HOUSE",
      "GRAPE",
      "BRUSH",
      "SMILE",
      "RIVER",
      "MUSIC",
      "PLANE",
      "WATER",
      "PAPER",
      "BREAD",
      "LIGHT",
      "PLANT",
      "BERRY",
      "FIELD",
      "CLOUD",
      "STORY",
      "EARTH",
    ],
    6: [
      "PLANET",
      "MARKET",
      "PENCIL",
      "KITTEN",
      "CANDLE",
      "GUITAR",
      "CASTLE",
      "BOTTLE",
      "GARDEN",
      "LANTERN",
      "CLOVER",
      "LADDER",
      "LANTERN",
      "FOLDER",
      "CANDLE",
      "BRANCH",
      "BUTTER",
      "FLOWER",
      "STREAM",
      "LANTERN",
    ],
    8: [
      "SUNSHINE",
      "NOTEBOOK",
      "ELEPHANT",
      "MANDARIN",
      "HOSPITAL",
      "CHESTNUT",
      "LAUGHTER",
      "MAGNETIC",
      "ADVENTURE",
      "SYMPHONY",
      "GIRAFFE",
      "MELODY",
      "ALPHABET",
      "TRIANGLE",
      "PINECONE",
      "CAMPFIRE",
      "HARMONIC",
      "SANDBOX",
      "GOLDEN",
      "JOURNAL",
    ],
  };

  return wordMap[length] ?? [];
}
