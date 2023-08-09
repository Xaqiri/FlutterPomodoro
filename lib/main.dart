import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

Future<void> _configureMacosWindowUtils() async {
  const config = MacosWindowUtilsConfig(
    toolbarStyle: NSWindowToolbarStyle.unified,
  );
  await config.apply();
}

void main() async {
  await _configureMacosWindowUtils();
  runApp(const MyApp());
}

enum TimerOptions { start, stop }

enum TimerType { work, rest }

class Pomodoro {
  int minutes = 0;
  int seconds = 0;
  TimerType type = TimerType.work;

  Pomodoro({required this.minutes, required this.seconds, required this.type});

  String time() {
    return '${minutes.toString()}:${seconds.toString().padLeft(2, "0")}';
  }

  @override
  String toString() {
    return switch (type) {
      TimerType.work => 'Work Timer',
      TimerType.rest => 'Break Timer'
    };
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      title: 'Pomodoro',
      theme: MacosThemeData.light(),
      darkTheme: MacosThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const MainView(title: 'Pomodoro'),
      debugShowCheckedModeBanner: false,
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
  final _workTimer = Pomodoro(minutes: 25, seconds: 0, type: TimerType.work);
  final _breakTimer = Pomodoro(minutes: 5, seconds: 0, type: TimerType.rest);
  late Pomodoro _curTimer;
  Timer? t;
  var _timerButtonIcon = const MacosIcon(CupertinoIcons.play);
  TimerOptions _timerAction = TimerOptions.start;
  var _tick = 0;

  @override
  void initState() {
    super.initState();
    _curTimer = _workTimer;
  }

  void _startTimer() {
    void tFunc(Timer timer) {
      setState(() {
        _tick++;
        _timerButtonIcon = const MacosIcon(CupertinoIcons.stop);
        _timerAction = TimerOptions.stop;
        _curTimer.seconds--;
        if (_curTimer.seconds < 0) {
          _curTimer.seconds = 59;
          _curTimer.minutes--;
        }
      });
      if (_curTimer.minutes == 0 && _curTimer.seconds == 0) {
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
      _timerButtonIcon = const MacosIcon(CupertinoIcons.play);
      _timerAction = TimerOptions.start;
    });
  }

  void _changeTimer() {
    setState(() {
      _curTimer = switch (_curTimer.type) {
        TimerType.work => _breakTimer,
        TimerType.rest => _workTimer
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return MacosWindow(
      child: MacosScaffold(
        toolBar: ToolBar(
          dividerColor: MacosColors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          title: Text(widget.title),
          actions: [
            ToolBarIconButton(
              label: switch (_timerAction) {
                TimerOptions.start => "Start timer",
                TimerOptions.stop => "Stop timer"
              },
              tooltipMessage: switch (_timerAction) {
                TimerOptions.start => "Start timer",
                TimerOptions.stop => "Stop timer"
              },
              icon: _timerButtonIcon,
              showLabel: false,
              onPressed: switch (_timerAction) {
                TimerOptions.start => _startTimer,
                TimerOptions.stop => _stopTimer
              },
            ),
            ToolBarIconButton(
              onPressed: _changeTimer,
              tooltipMessage: 'Change Timer',
              label: 'Change Timer',
              showLabel: false,
              icon: const MacosIcon(CupertinoIcons.restart),
            ),
          ],
        ),
        children: [
          ContentArea(
            builder: ((context, scrollController) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 1000,
                      child: Column(children: [
                        ProgressBar(
                            height: 10,
                            value: 100 / 60 * _curTimer.minutes.toDouble()),
                        ProgressBar(
                            height: 10,
                            value: 100 / 60 * _curTimer.seconds.toDouble()),
                      ]),
                    ),
                    Text(
                      _curTimer.toString(),
                      style: const TextStyle(
                        fontSize: 32,
                      ),
                    ),
                    Text(
                      _curTimer.time(),
                      style: const TextStyle(fontSize: 32),
                    ),
                    SizedBox(
                      width: 200,
                      child: MacosSlider(
                        value: max(1, _curTimer.minutes.toDouble()),
                        min: 1,
                        max: 60,
                        onChanged: (double value) {
                          setState(() {
                            _curTimer.minutes = value.toInt();
                            _curTimer.seconds = 0;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
