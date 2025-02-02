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
  Map<String, bool> fetchableWords = {};
  String _selectedDifficulty = 'All';

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

  Future<void> _checkFetchableWords() async {
    for (String word in successfullyGuessedWords) {
      if (!fetchableWords.containsKey(word)) {
        fetchableWords[word] = await _isWordFetchable(word);
      }
    }
    setState(() {});
  }

  Future<bool> _isWordFetchable(String word) async {
    final response = await http.get(
      Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'),
    );
    return response.statusCode == 200;
  }

  void _updateFilteredWords() {
    List<String> baseList;
    switch (_selectedDifficulty) {
      case 'Easy':
        baseList = easyGuessedWords;
        break;
      case 'Hard':
        baseList = hardGuessedWords;
        break;
      case 'Nightmare':
        baseList = nightmareGuessedWords;
        break;
      default:
        baseList = successfullyGuessedWords;
    }
    filteredWords =
        baseList
            .where(
              (word) => word.toLowerCase().contains(
                _searchController.text.toLowerCase(),
              ),
            )
            .toList();
    _sortWords();
  }

  Color _getDifficultyColor(String word) {
    if (word.length == 5) return Colors.green.shade800;
    if (word.length == 6) return Colors.orange.shade800;
    if (word.length == 8) return Colors.red.shade800;
    return Colors.grey.shade800;
  }

  String _getDifficultyLabel(String word) {
    if (word.length == 5) return 'EASY';
    if (word.length == 6) return 'HARD';
    if (word.length == 8) return 'NIGHTMARE';
    return 'UNKNOWN';
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

  void _sortWords() {
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
    setState(() {});
  }

  void _changeSortOption() {
    setState(() {
      _currentSort =
          SortOption.values[(_currentSort.index + 1) %
              SortOption.values.length];
      _sortWords();
    });
  }

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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 23, 0, 31),
              Color.fromARGB(255, 54, 0, 73),
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => _updateFilteredWords(),
                          decoration: InputDecoration(
                            hintText: 'Search words...',
                            hintStyle: TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.grey[800]!.withOpacity(0.7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.white70,
                            ),
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
                  SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          ['All', 'Easy', 'Hard', 'Nightmare'].map((
                            difficulty,
                          ) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: ChoiceChip(
                                label: Text(difficulty),
                                selected: _selectedDifficulty == difficulty,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedDifficulty =
                                        selected ? difficulty : 'All';
                                    _updateFilteredWords();
                                  });
                                },
                                selectedColor: _getDifficultyColor(
                                  difficulty == 'Easy'
                                      ? 'easy' // Example word length
                                      : difficulty == 'Hard'
                                      ? 'harder' // Example word length
                                      : 'nightmare',
                                ),
                                labelStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                backgroundColor: Colors.grey[800],
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredWords.length,
                itemBuilder: (context, index) {
                  final word = filteredWords[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: _getDifficultyColor(word),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        title: Text(
                          word.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _getDifficultyLabel(word),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        onTap: () => _showWordDetails(word),
                      ),
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
