import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

enum TimerOptions { start, stop }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
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
  TimerOptions _timerAction = TimerOptions.start;
  var _tick = 0;

  @override
  void initState() {
    super.initState();
  }

  void _startTimer() {
    void tFunc(Timer timer) {
      setState(() {
        _tick++;
        _timerButtonIcon = const Icon(Icons.stop);
        _timerAction = TimerOptions.stop;
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
      _timerAction = TimerOptions.start;
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
        child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Theme.of(context).colorScheme.inversePrimary,
                Theme.of(context).colorScheme.primary,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Work Timer',
                style: TextStyle(
                  fontSize: 32,
                ),
              ),
              Text(
                '$_minutesDisplay:$_secondsDisplay',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              SizedBox(
                width: 200,
                child: Slider(
                  value: max(1.0, _minutes.toDouble()),
                  min: 1,
                  max: 60,
                  label: _minutes.toString(),
                  onChanged: (double value) {
                    setState(() {
                      _minutes = value.toInt();
                      _seconds = 0;
                      setTimerDisplay();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        onPressed: switch (_timerAction) {
          TimerOptions.start => _startTimer,
          TimerOptions.stop => _stopTimer
        },
        tooltip: switch (_timerAction) {
          TimerOptions.start => "Start timer",
          TimerOptions.stop => "Stop timer"
        },
        child: _timerButtonIcon,
      ),
    );
  }
}
