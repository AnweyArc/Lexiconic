import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'gamepreference.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    playBackgroundMusic();
  }

  Future<void> playBackgroundMusic() async {
    try {
      print("Loading audio...");
      await _audioPlayer.setAudioSource(
        AudioSource.asset('assets/audio/BackgroundMusic.mp3'),
      );

      _audioPlayer.setLoopMode(LoopMode.all);
      _audioPlayer.setVolume(1.0);

      await _audioPlayer.play();
      print("Playing audio...");
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, double> _scaleMap = {
    "Play": 1.0,
    "Achievements": 1.0,
    "Settings": 1.0,
    "Dictionary": 1.0,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lexiconic',
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMenuButton(
                context,
                "Play",
                Icons.play_arrow,
                Colors.green,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GamePreferenceScreen(),
                  ),
                ),
              ),
              _buildMenuButton(
                context,
                "Achievements",
                Icons.emoji_events,
                Colors.orange,
                () {},
              ),
              _buildMenuButton(
                context,
                "Settings",
                Icons.settings,
                Colors.blue,
                () {},
              ),
              _buildMenuButton(
                context,
                "Dictionary",
                Icons.book,
                Colors.purple,
                () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String text,
    IconData icon,
    Color buttonColor,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
      child: MouseRegion(
        onEnter: (_) => _onHover(true, text),
        onExit: (_) => _onHover(false, text),
        child: AnimatedScale(
          scale: _scaleMap[text]!,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: InkWell(
            onTap: onPressed,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
              decoration: BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: buttonColor.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 28, color: Colors.white),
                  SizedBox(width: 16),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'LibreFranklin',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onHover(bool isHovered, String buttonText) {
    setState(() {
      _scaleMap[buttonText] = isHovered ? 1.1 : 1.0;
    });
  }
}
