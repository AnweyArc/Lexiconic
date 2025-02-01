// settings.dart
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final AudioPlayer audioPlayer;

  SettingsScreen({required this.audioPlayer});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isBackgroundMusicEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load the background music setting from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBackgroundMusicEnabled = prefs.getBool('backgroundMusic') ?? true;
    });
  }

  // Save the background music setting to SharedPreferences
  Future<void> _saveSettings(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('backgroundMusic', value);

  if (value) {
    if (widget.audioPlayer.processingState == ProcessingState.idle) {
      await widget.audioPlayer.setAudioSource(AudioSource.asset('assets/audio/BackgroundMusic.mp3'));
    }
    await widget.audioPlayer.setLoopMode(LoopMode.all);
    await widget.audioPlayer.play();
  } else {
    await widget.audioPlayer.pause();
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                color: Colors.grey[800]!.withOpacity(0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  title: Text(
                    'Background Music',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'LibreFranklin',
                      color: Colors.white,
                    ),
                  ),
                  trailing: Switch(
                    value: _isBackgroundMusicEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isBackgroundMusicEnabled = value;
                      });
                      _saveSettings(
                        value,
                      ); // Save the setting and control the music
                    },
                    activeColor: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
