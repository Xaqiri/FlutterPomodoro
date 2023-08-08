import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

enum timerOptions { start, stop }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainView(title: 'Pomodoro'),
    );
  }
}

class MainView extends StatefulWidget {
  const MainView({super.key, required this.title});
  final String title;

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _minutes = 1;
  String _minutesDisplay = "1";
  int _seconds = 0;
  String _secondsDisplay = "00";
  Timer? t;
  Icon _timerButtonIcon = const Icon(Icons.play_arrow);
  timerOptions _timerAction = timerOptions.start;
  var _tick = 0;

  @override
  void initState() {
    super.initState();
  }

  void _decrementMinutes() {
    setState(() {
      _minutes--;
      _minutesDisplay = _minutes.toString();
      _seconds = 0;
      setTimerDisplay();
    });
  }

  void _incrementMinutes() {
    setState(() {
      _minutes++;
      _minutesDisplay = _minutes.toString();
      _seconds = 0;
      setTimerDisplay();
    });
  }

  void _startTimer() {
    void tFunc(Timer timer) {
      setState(() {
        _tick++;
        _timerButtonIcon = const Icon(Icons.stop);
        _timerAction = timerOptions.stop;
        _seconds--;
        if (_seconds < 0) {
          _seconds = 59;
          _minutes--;
        }
        setTimerDisplay();
      });
      if (_minutes == 0 && _seconds == 0) {
        timer.cancel();
      }
      if (_tick == 1) {
        timer.cancel();
      }
    }

    t = Timer.periodic(const Duration(seconds: 0), tFunc);
    t = Timer.periodic(const Duration(seconds: 1), tFunc);
  }

  void _stopTimer() {
    setState(() {
      t!.cancel();
      _tick = 0;
      _timerButtonIcon = const Icon(Icons.play_arrow);
      _timerAction = timerOptions.start;
    });
  }

  void setTimerDisplay() {
    setState(() {
      _minutesDisplay = "$_minutes";
      _seconds < 10
          ? _secondsDisplay = "0$_seconds"
          : _secondsDisplay = "$_seconds";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Work Timer',
            ),
            Text(
              '$_minutesDisplay:$_secondsDisplay',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FilledButton(
                  onPressed: _decrementMinutes,
                  child: const Icon(Icons.remove),
                ),
                FilledButton(
                  onPressed: _incrementMinutes,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: switch (_timerAction) {
          timerOptions.start => _startTimer,
          timerOptions.stop => _stopTimer
        },
        tooltip: switch (_timerAction) {
          timerOptions.start => "Start timer",
          timerOptions.stop => "Stop timer"
        },
        child: _timerButtonIcon,
      ),
    );
  }
}
