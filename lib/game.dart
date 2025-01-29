import 'package:flutter/material.dart';
import 'dart:math';
import 'fetchdata.dart';

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
    if (targetWord.contains(letter)) return Colors.yellow;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wordle Game (${widget.difficulty.capitalize()})"),
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
                  ],
                ),
              ),
      backgroundColor: const Color.fromARGB(255, 27, 25, 25),
    );
  }

  Widget buildInputSection() {
    return Column(
      children: [
        TextField(
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
