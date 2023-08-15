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
