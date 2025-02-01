import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'data_info.dart';

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
    loadGuessedWords().then((_) {
      setState(() {
        filteredWords = successfullyGuessedWords.take(5).toList();
      });
    });
  }

  void _filterWords(String query) {
    setState(() {
      filteredWords =
          successfullyGuessedWords
              .where((word) => word.toLowerCase().contains(query.toLowerCase()))
              .take(5)
              .toList();
    });
  }

  Future<Map<String, dynamic>> fetchWordDetails(String word) async {
    final response = await http.get(
      Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.first;
    } else {
      throw Exception('Failed to load word details');
    }
  }

  void _showWordDetails(String word) async {
    try {
      Map<String, dynamic> wordData = await fetchWordDetails(word);
      List<dynamic> meanings = wordData['meanings'];

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              word,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    meanings.map((meaning) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meaning['partOfSpeech'] ?? '',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ...meaning['definitions'].map<Widget>((definition) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Text(
                                  "- ${definition['definition']}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
            actions: [
              TextButton(
                child: Text("Close", style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch details for $word")),
      );
    }
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
                  suffixIcon:
                      _searchController.text.isNotEmpty
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
                      onTap: () => _showWordDetails(filteredWords[index]),
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
