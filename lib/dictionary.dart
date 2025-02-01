import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'data_info.dart';

class DictionaryScreen extends StatefulWidget {
  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

enum SortOption { longest, shortest, recent, unrecent, fetchable }

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> filteredWords = [];
  SortOption _currentSort = SortOption.recent;
  Map<String, bool> fetchableWords = {}; // Caches words that can be fetched

  @override
  void initState() {
    super.initState();
    loadGuessedWords().then((_) {
      setState(() {
        filteredWords = List.from(successfullyGuessedWords);
        _sortWords();
        _checkFetchableWords();
      });
    });
  }

  /// Fetches word details to determine fetchability
  Future<void> _checkFetchableWords() async {
    for (String word in successfullyGuessedWords) {
      if (!fetchableWords.containsKey(word)) {
        fetchableWords[word] = await _isWordFetchable(word);
      }
    }
    setState(() {}); // Update UI after checking
  }

  /// Determines if a word has fetchable details
  Future<bool> _isWordFetchable(String word) async {
    final response = await http.get(
      Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'),
    );
    return response.statusCode == 200;
  }

  /// Filters words based on search input
  void _filterWords(String query) {
    setState(() {
      filteredWords =
          successfullyGuessedWords
              .where((word) => word.toLowerCase().contains(query.toLowerCase()))
              .toList();
      _sortWords();
    });
  }

  /// Fetches word details
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

  /// Shows word details in a dialog
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

  /// Sorts words based on selected sorting option
  void _sortWords() {
    setState(() {
      switch (_currentSort) {
        case SortOption.longest:
          filteredWords.sort((a, b) => b.length.compareTo(a.length));
          break;
        case SortOption.shortest:
          filteredWords.sort((a, b) => a.length.compareTo(b.length));
          break;
        case SortOption.recent:
          filteredWords = List.from(successfullyGuessedWords);
          break;
        case SortOption.unrecent:
          filteredWords = List.from(successfullyGuessedWords.reversed);
          break;
        case SortOption.fetchable:
          filteredWords =
              successfullyGuessedWords
                  .where((word) => fetchableWords[word] ?? false)
                  .toList();
          break;
      }
    });
  }

  /// Cycles through sorting options and updates UI
  void _changeSortOption() {
    setState(() {
      _currentSort =
          SortOption.values[(_currentSort.index + 1) %
              SortOption.values.length]; // Cycle options
      _sortWords();
    });
  }

  /// Gets sorting icon based on current option
  IconData _getSortIcon() {
    switch (_currentSort) {
      case SortOption.longest:
        return Icons.sort_by_alpha;
      case SortOption.shortest:
        return Icons.short_text;
      case SortOption.recent:
        return Icons.schedule;
      case SortOption.unrecent:
        return Icons.history;
      case SortOption.fetchable:
        return Icons.check_circle_outline;
      default:
        return Icons.sort;
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
              child: Row(
                children: [
                  Expanded(
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
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: Icon(_getSortIcon(), color: Colors.white),
                    onPressed: _changeSortOption,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredWords.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      filteredWords[index],
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    onTap: () => _showWordDetails(filteredWords[index]),
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
