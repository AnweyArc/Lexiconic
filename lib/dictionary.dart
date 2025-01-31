import 'package:flutter/material.dart';
import 'data_info.dart'; // Import the shared data file

class DictionaryScreen extends StatefulWidget {
  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> filteredWords = [];

  @override
  void initState() {
    super.initState();
    // Load the guessed words when the screen is opened
    loadGuessedWords().then((_) {
      setState(() {
        // Initialize filteredWords with the 5 most recent guessed words
        filteredWords = successfullyGuessedWords
            .take(5)
            .toList(); // Only show the 5 most recent words
      });
    });
  }

  void _filterWords(String query) {
    setState(() {
      filteredWords = successfullyGuessedWords
          .where((word) => word.toLowerCase().contains(query.toLowerCase()))
          .take(5) // Limit to 5 results
          .toList();
    });
  }

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
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _filterWords,
                decoration: InputDecoration(
                  hintText: 'Search words...',
                  hintStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800]!.withOpacity(0.7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.white70),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.white70),
                          onPressed: () {
                            _searchController.clear();
                            _filterWords('');
                          },
                        )
                      : null,
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
            // List of Words
            Expanded(
              child: ListView.builder(
                itemCount: filteredWords.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.grey[800]!.withOpacity(0.7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: Text(
                        filteredWords[index],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'LibreFranklin',
                          color: Colors.white,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white70,
                      ),
                      onTap: () {
                        // Add functionality when a word is tapped
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}