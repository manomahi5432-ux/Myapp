import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const GuessingGameApp());
}

// Global data model for game history
class GameRecord {
  final DateTime date;
  final int targetNumber;
  final int totalAttempts;
  final bool isWon;

  GameRecord({
    required this.date,
    required this.targetNumber,
    required this.totalAttempts,
    required this.isWon,
  });
}

// State container passed down the widget tree
class GuessingGameApp extends StatefulWidget {
  const GuessingGameApp({super.key});

  @override
  State<GuessingGameApp> createState() => _GuessingGameAppState();
}

class _GuessingGameAppState extends State<GuessingGameApp> {
  // Global history state shared across views
  final List<GameRecord> _gameHistory = [];

  void _addGameRecord(GameRecord record) {
    setState(() {
      _gameHistory.insert(0, record); // Newest games show first
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Guessing Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),
      home: MainScreen(
        history: _gameHistory,
        onGameFinished: _addGameRecord,
      ),
    );
  }
}

// ==========================================
// 1. MAIN SCREEN
// ==========================================
class MainScreen extends StatelessWidget {
  final List<GameRecord> history;
  final ValueChanged<GameRecord> onGameFinished;

  const MainScreen({
    super.key,
    required this.history,
    required this.onGameFinished,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade100, Colors.white],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.casino,
                  size: 100,
                  color: Colors.deepPurple.shade700,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Guess the Number!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Can you crack the code? Match the mystery number between 1 and 100.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start New Game'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GamePlayingScreen(
                          onGameFinished: onGameFinished,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.history),
                  label: const Text('View History'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryScreen(history: history),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. GAME PLAYING SCREEN
// ==========================================
class GamePlayingScreen extends StatefulWidget {
  final ValueChanged<GameRecord> onGameFinished;

  const GamePlayingScreen({super.key, required this.onGameFinished});

  @override
  State<GamePlayingScreen> createState() => _GamePlayingScreenState();
}

class _GamePlayingScreenState extends State<GamePlayingScreen> {
  late int _targetNumber;
  int _attemptsCount = 0;
  final int _maxAttempts = 7;
  String _hintMessage = 'Enter a value to make your first move!';
  bool _isGameOver = false;
  bool _isWon = false;

  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startNewSession();
  }

  void _startNewSession() {
    setState(() {
      _targetNumber = Random().nextInt(100) + 1; // Range: 1 to 100
      _attemptsCount = 0;
      _hintMessage = 'Enter a value to make your first move!';
      _isGameOver = false;
      _isWon = false;
      _inputController.clear();
    });
  }

  void _evaluateGuess() {
    final String input = _inputController.text.trim();
    final int? guessedValue = int.tryParse(input);

    if (guessedValue == null || guessedValue < 1 || guessedValue > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please submit a clean round number between 1 and 100.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _attemptsCount++;

      if (guessedValue == _targetNumber) {
        _isGameOver = true;
        _isWon = true;
        _hintMessage = 'Brilliant! $_targetNumber is exactly correct!';
        _saveMatchRecord();
      } else if (_attemptsCount >= _maxAttempts) {
        _isGameOver = true;
        _isWon = false;
        _hintMessage = 'Out of turns! The target value was $_targetNumber.';
        _saveMatchRecord();
      } else if (guessedValue < _targetNumber) {
        _hintMessage = 'Higher! Try picking a larger number.';
      } else {
        _hintMessage = 'Lower! Try picking a smaller number.';
      }
    });

    _inputController.clear();
  }

  void _saveMatchRecord() {
    widget.onGameFinished(
      GameRecord(
        date: DateTime.now(),
        targetNumber: _targetNumber,
        totalAttempts: _attemptsCount,
        isWon: _isWon,
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playing Screen'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: _attemptsCount / _maxAttempts,
                backgroundColor: Colors.grey.shade200,
                color: _attemptsCount > (_maxAttempts - 2)
                    ? Colors.red
                    : Colors.deepPurple,
              ),
              const SizedBox(height: 12),
              Text(
                'Attempts remaining: ${_maxAttempts - _attemptsCount}',
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 40),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        'Target range matches:',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isGameOver ? '$_targetNumber' : '1 - 100',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: _isGameOver
                              ? (_isWon ? Colors.green : Colors.red)
                              : Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _hintMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _inputController,
                keyboardType: TextInputType.number,
                enabled: !_isGameOver,
                autofocus: true,
