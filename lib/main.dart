import 'dart:async';
import 'package:flutter/material.dart';

// Main function to run the app
void main() {
  runApp(const PomodoroApp());
}

// The root widget of the application
class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro Timer',
      debugShowCheckedModeBanner: false,
      // Define the overall theme of the app, focusing on a blue color scheme
      theme: ThemeData(
        primaryColor: const Color(0xFF1E3A8A), // A deep blue for primary elements
        scaffoldBackgroundColor: const Color(0xFF0F172A), // A very dark blue for the background
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6), // A bright, friendly blue for interactive elements
          secondary: Color(0xFF60A5FA), // A lighter blue for accents
          onPrimary: Colors.white, // Text color on primary elements
          onSecondary: Colors.white, // Text color on secondary elements
          background: Color(0xFF0F172A),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold, color: Colors.white),
          titleLarge: TextStyle(fontSize: 24.0, fontStyle: FontStyle.italic, color: Colors.white70),
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6), // Bright blue for buttons
            foregroundColor: Colors.white, // White text for buttons
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      home: const PomodoroTimerScreen(),
    );
  }
}

// The main screen of the Pomodoro timer, which is stateful
class PomodoroTimerScreen extends StatefulWidget {
  const PomodoroTimerScreen({super.key});

  @override
  State<PomodoroTimerScreen> createState() => _PomodoroTimerScreenState();
}

class _PomodoroTimerScreenState extends State<PomodoroTimerScreen> {
  // Constants for timer durations in seconds
  static const int _pomodoroDuration = 25 * 60; // 25 minutes
  static const int _shortBreakDuration = 5 * 60;  // 5 minutes
  static const int _longBreakDuration = 15 * 60; // 15 minutes

  // Timer state variables
  late int _remainingTime;
  Timer? _timer;
  bool _isRunning = false;
  String _currentMode = 'Pomodoro'; // Can be 'Pomodoro', 'Short Break', or 'Long Break'
  int _pomodoroCycleCount = 0; // Tracks completed Pomodoro sessions

  @override
  void initState() {
    super.initState();
    _resetTimer(); // Initialize timer state
  }

  @override
  void dispose() {
    _timer?.cancel(); // Clean up the timer when the widget is removed
    super.dispose();
  }

  /// Resets the timer to the duration of the current mode.
  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      switch (_currentMode) {
        case 'Pomodoro':
          _remainingTime = _pomodoroDuration;
          break;
        case 'Short Break':
          _remainingTime = _shortBreakDuration;
          break;
        case 'Long Break':
          _remainingTime = _longBreakDuration;
          break;
      }
    });
  }

  /// Starts or pauses the timer.
  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      // Start a periodic timer that ticks every second
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingTime > 0) {
            _remainingTime--;
          } else {
            _timer?.cancel();
            _isRunning = false;
            _moveToNextMode();
          }
        });
      });
    }
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  /// Switches the timer to the next mode in the Pomodoro cycle.
  void _moveToNextMode() {
    if (_currentMode == 'Pomodoro') {
      _pomodoroCycleCount++;
      if (_pomodoroCycleCount % 4 == 0) {
        _setMode('Long Break');
      } else {
        _setMode('Short Break');
      }
    } else {
      _setMode('Pomodoro');
    }
  }

  /// Sets the timer mode and resets the timer.
  void _setMode(String mode) {
    setState(() {
      _currentMode = mode;
      _resetTimer();
    });
  }

  /// Formats the remaining time in MM:SS format.
  String get _formattedTime {
    final minutes = (_remainingTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingTime % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Returns the total duration for the current mode.
  int get _totalDuration {
    switch (_currentMode) {
      case 'Pomodoro':
        return _pomodoroDuration;
      case 'Short Break':
        return _shortBreakDuration;
      case 'Long Break':
        return _longBreakDuration;
      default:
        return _pomodoroDuration;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mode selection buttons
              _buildModeSelector(),
              const SizedBox(height: 40),

              // Circular progress timer display
              _buildTimerDisplay(),
              const SizedBox(height: 40),

              // Control buttons (start/pause, reset)
              _buildControlButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ModeButton(
          label: 'Pomodoro',
          isSelected: _currentMode == 'Pomodoro',
          onPressed: () => _setMode('Pomodoro'),
        ),
        const SizedBox(width: 10),
        _ModeButton(
          label: 'Short Break',
          isSelected: _currentMode == 'Short Break',
          onPressed: () => _setMode('Short Break'),
        ),
        const SizedBox(width: 10),
        _ModeButton(
          label: 'Long Break',
          isSelected: _currentMode == 'Long Break',
          onPressed: () => _setMode('Long Break'),
        ),
      ],
    );
  }

  Widget _buildTimerDisplay() {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Circular progress indicator
          CircularProgressIndicator(
            value: _remainingTime / _totalDuration,
            strokeWidth: 12,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          // Time text in the center
          Center(
            child: Text(
              _formattedTime,
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Start/Pause button
        ElevatedButton(
          onPressed: _toggleTimer,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(140, 50),
          ),
          child: Text(
            _isRunning ? 'PAUSE' : 'START',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 20),
        // Reset button
        IconButton(
          onPressed: _resetTimer,
          icon: const Icon(Icons.refresh),
          iconSize: 35,
          color: Colors.white,
        ),
      ],
    );
  }
}

/// A custom button widget for selecting the timer mode.
class _ModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _ModeButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
          backgroundColor: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : Colors.transparent,
          foregroundColor: isSelected
              ? Colors.white
              : Colors.grey[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.withOpacity(0.5),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
      ),
      child: Text(label),
    );
  }
}
