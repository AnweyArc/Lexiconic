import 'package:flutter/material.dart';
import 'dart:math';
import 'fetchdata.dart';
import 'data_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordleHomePage extends StatefulWidget {
  final String difficulty;

  WordleHomePage({required this.difficulty});

  @override
  _WordleHomePageState createState() => _WordleHomePageState();
}

class _WordleHomePageState extends State<WordleHomePage> {
  List<String> wordList = [];
  late String targetWord;
  List<String> guesses = [];
  String currentGuess = "";
  late int wordLength;
  late int maxAttempts;
  bool gameWon = false;
  bool isLoading = true;
  bool showKeyboard = false;

  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    wordLength = _getWordLength(widget.difficulty);
    maxAttempts = _getMaxAttempts(widget.difficulty);
    fetchWords(widget.difficulty).then((words) {
      setState(() {
        wordList = words.where((word) => word.length == wordLength).toList();
        targetWord = wordList[Random().nextInt(wordList.length)];
        isLoading = false;
      });
    });

    // Load the guessed words when the game starts
    loadGuessedWords();
  }

  int _getWordLength(String difficulty) {
    switch (difficulty) {
      case 'hard':
        return 6;
      case 'nightmare':
        return 8;
      default:
        return 5;
    }
  }

  int _getMaxAttempts(String difficulty) {
    switch (difficulty) {
      case 'hard':
        return 7;
      case 'nightmare':
        return 10;
      default:
        return 5;
    }
  }

  void checkGuess() {
    if (currentGuess.length != wordLength || gameWon) return;

    if (guesses.contains(currentGuess)) {
      showAlertDialog("Word already guessed!");
      return;
    }

    setState(() {
      guesses.add(currentGuess);
      if (currentGuess == targetWord) {
        gameWon = true;
        successfullyGuessedWords.add(targetWord); // Add to global list
        saveGuessedWords(); // Save the updated list to SharedPreferences
        showEndDialog("Congratulations! You guessed the word!");
      } else if (guesses.length >= maxAttempts) {
        showEndDialog("Game Over! The word was $targetWord.");
      }
      currentGuess = "";
      _controller.clear();
    });
  }

  void showAlertDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Notice"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("OK"),
              ),
            ],
          ),
    );
  }

  void showEndDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Game Over"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  resetGame();
                },
                child: Text("Play Again"),
              ),
            ],
          ),
    );
  }

  void resetGame() {
    setState(() {
      targetWord = wordList[Random().nextInt(wordList.length)];
      guesses.clear();
      currentGuess = "";
      gameWon = false;
      _controller.clear();
    });
  }

  Color getColor(String letter, int index, String guess) {
    if (targetWord[index] == letter) return Colors.green;
    if (targetWord.contains(letter)) return Colors.orange;
    return Colors.grey;
  }

  void toggleKeyboard() {
    setState(() {
      showKeyboard = !showKeyboard;
    });
  }

  void onKeyPressed(String key) {
    if (currentGuess.length < wordLength) {
      setState(() {
        currentGuess += key;
        _controller.text = currentGuess;
      });
    }
  }

  void onBackspacePressed() {
    if (currentGuess.isNotEmpty) {
      setState(() {
        currentGuess = currentGuess.substring(0, currentGuess.length - 1);
        _controller.text = currentGuess;
      });
    }
  }

  Color getKeyColor(String key) {
    // Check if the key has been used in any guess
    bool hasBeenUsed = guesses.any((guess) => guess.contains(key));

    // If the key has not been used, return grey
    if (!hasBeenUsed) return Colors.grey;

    // Check if the key is in the correct position in any guess
    for (String guess in guesses) {
      for (int i = 0; i < guess.length; i++) {
        if (guess[i] == key && targetWord[i] == key) {
          return Colors.green; // Correct position
        }
      }
    }

    // Check if the key is in the word but not in the correct position
    if (targetWord.contains(key)) {
      return Colors.orange; // Correct letter, wrong position
    }

    // If the key has been used and is not in the word, return red
    return Colors.black;
  }

  bool isKeyDisabled(String key) {
    // Disable the key only if it has been used and is not in the target word
    return guesses.any((guess) => guess.contains(key)) &&
        !targetWord.contains(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Wordle Game (${widget.difficulty.capitalize()})",
          style: TextStyle(
            fontFamily: 'LibreFranklin',
            fontSize: 24,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor:
            widget.difficulty == "easy"
                ? Colors.green
                : widget.difficulty == "hard"
                ? Colors.orange
                : Colors.red,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Remaining Attempts: ${maxAttempts - guesses.length}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: DifficultyTable(
                        wordLength: wordLength,
                        guesses: guesses,
                        getColor: getColor,
                      ),
                    ),
                    buildInputSection(),
                    if (showKeyboard) buildCustomKeyboard(context),
                  ],
                ),
              ),
      backgroundColor: const Color.fromARGB(255, 27, 25, 25),
    );
  }

  Widget buildInputSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLength: wordLength,
                enabled: !gameWon,
                onChanged: (value) {
                  setState(() {
                    currentGuess = value.toUpperCase();
                  });
                },
                onSubmitted: (_) => checkGuess(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter your guess",
                  hintStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
              ),
            ),
            SizedBox(width: 8.0),
            IconButton(
              icon: Icon(Icons.keyboard, color: Colors.white),
              onPressed: toggleKeyboard,
            ),
          ],
        ),
        SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: gameWon ? null : checkGuess,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.send, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Submit Guess",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'LibreFranklin',
                  color: Colors.white,
                ),
              ),
            ],
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
          ),
        ),
      ],
    );
  }

  Widget buildCustomKeyboard(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Adjust these values to make the keys smaller or larger
    final double keyWidth =
        screenWidth /
        16; // Smaller keys (increase divisor to make them smaller)
    final double keyHeight =
        keyWidth * 1.8; // Slightly taller than wide (adjust multiplier)

    return Container(
      padding: EdgeInsets.all(8.0),
      color: Colors.grey[900],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P']
                    .map(
                      (key) => KeyboardKey(
                        keyLabel: key,
                        onKeyPressed: isKeyDisabled(key) ? null : onKeyPressed,
                        color: getKeyColor(key),
                        width: keyWidth,
                        height: keyHeight,
                      ),
                    )
                    .toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L']
                    .map(
                      (key) => KeyboardKey(
                        keyLabel: key,
                        onKeyPressed: isKeyDisabled(key) ? null : onKeyPressed,
                        color: getKeyColor(key),
                        width: keyWidth,
                        height: keyHeight,
                      ),
                    )
                    .toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KeyboardKey(
                keyLabel: '⌫',
                onKeyPressed: (_) => onBackspacePressed(),
                color: Colors.grey,
                width:
                    keyWidth *
                    1.4, // Adjust this multiplier for backspace width
                height: keyHeight,
              ),
              ...['Z', 'X', 'C', 'V', 'B', 'N', 'M'].map(
                (key) => KeyboardKey(
                  keyLabel: key,
                  onKeyPressed: isKeyDisabled(key) ? null : onKeyPressed,
                  color: getKeyColor(key),
                  width: keyWidth,
                  height: keyHeight,
                ),
              ),
              KeyboardKey(
                keyLabel: 'Enter',
                onKeyPressed: (_) => checkGuess(),
                color: Colors.grey,
                width: keyWidth * 1.2, // Adjust this multiplier for enter width
                height: keyHeight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class KeyboardKey extends StatelessWidget {
  final String keyLabel;
  final Function(String)? onKeyPressed;
  final Color color;
  final double width;
  final double height;

  const KeyboardKey({
    required this.keyLabel,
    required this.onKeyPressed,
    required this.color,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(4.0),
        child: InkWell(
          onTap: onKeyPressed == null ? null : () => onKeyPressed!(keyLabel),
          child: Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            child: Text(
              keyLabel,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DifficultyTable extends StatelessWidget {
  final int wordLength;
  final List<String> guesses;
  final Color Function(String letter, int index, String guess) getColor;

  const DifficultyTable({
    required this.wordLength,
    required this.guesses,
    required this.getColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: guesses.length,
      itemBuilder: (context, index) {
        String guess = guesses[index];
        return FittedBox(
          fit: BoxFit.contain,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(wordLength, (i) {
              return Container(
                margin: EdgeInsets.all(4.0),
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: getColor(guess[i], i, guess),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  guess[i],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return this.isEmpty ? this : '${this[0].toUpperCase()}${this.substring(1)}';
  }
}
