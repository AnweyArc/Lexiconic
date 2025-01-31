// dictionary.dart
import 'package:flutter/material.dart';
import 'data_info.dart'; // Import the shared data file

class DictionaryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dictionary',
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
          image: DecorationImage(
            image: AssetImage("assets/images/homebackground.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView.builder(
          itemCount: successfullyGuessedWords.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                successfullyGuessedWords[index],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'LibreFranklin',
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}