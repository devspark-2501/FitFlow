import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import 'alarm_section.dart';

// 1. MAIN PAGE WIDGET
class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Timer & Alarm"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.hourglass_bottom), text: "Timer"),
            Tab(icon: Icon(Icons.timer), text: "Stopwatch"),
            Tab(icon: Icon(Icons.alarm), text: "Alarm"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TimerSection(audioPlayer: _audioPlayer),
          const StopwatchSection(),
          AlarmSection(audioPlayer: _audioPlayer),
        ],
      ),
    );
  }
}

// 2. TIMER SECTION
class TimerSection extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const TimerSection({super.key, required this.audioPlayer});

  @override
  State<TimerSection> createState() => _TimerSectionState();
}

class _TimerSectionState extends State<TimerSection> {
  Timer? _timer;
  int _initialSeconds = 60;
  int _remainingSeconds = 60;
  bool _isRunning = false;
  bool _isRinging = false;

  final List<Map<String, String>> _history = [];

  void _startTimer() {
    if (_remainingSeconds <= 0) return;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _triggerAlarm();
      }
    });
  }

  void _triggerAlarm() async {
    _pauseTimer();
    setState(() => _isRinging = true);
    await widget.audioPlayer.setReleaseMode(ReleaseMode.loop);
    await widget.audioPlayer.play(AssetSource('alarm_sound.mp3'));

    _history.insert(0, {
      'duration': _formatTime(_initialSeconds),
      'completedAt': TimeOfDay.now().format(context),
    });
  }

  void _stopAlarmSound() async {
    await widget.audioPlayer.stop();
    setState(() {
      _isRinging = false;
      _remainingSeconds = _initialSeconds;
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _pauseTimer();
    _stopAlarmSound();
    setState(() => _remainingSeconds = _initialSeconds);
  }

  void _showTimerPicker() {
    if (_isRunning || _isRinging) return;

    Duration tempDuration = Duration(seconds: _remainingSeconds);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const Text("Set Duration", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  TextButton(
                    onPressed: () {
                      if (tempDuration.inSeconds > 0) {
                        setState(() {
                          _initialSeconds = tempDuration.inSeconds;
                          _remainingSeconds = tempDuration.inSeconds;
                        });
                      }
                      Navigator.pop(context);
                    },
                    child: const Text("Done"),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.ms,
                  initialTimerDuration: tempDuration,
                  onTimerDurationChanged: (d) => tempDuration = d,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$mins:$secs";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          GestureDetector(
            onTap: _showTimerPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                color: _isRinging ? Colors.red.withOpacity(0.1) : primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _isRinging ? Colors.red : primary.withOpacity(0.2), width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: _isRinging ? Colors.red : primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isRinging ? "⏰ TIME'S UP!" : "Tap to adjust duration",
                    style: TextStyle(
                      color: _isRinging ? Colors.red : primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (_isRinging)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              onPressed: _stopAlarmSound,
              icon: const Icon(Icons.alarm_off),
              label: const Text("STOP SOUND", style: TextStyle(fontWeight: FontWeight.bold)),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.large(
                  backgroundColor: primary,
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  child: Icon(_isRunning ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 36),
                ),
                const SizedBox(width: 20),
                IconButton(
                  iconSize: 36,
                  icon: const Icon(Icons.refresh),
                  onPressed: _resetTimer,
                ),
              ],
            ),

          const SizedBox(height: 32),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("Recent Timer History", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 12),
          if (_history.isEmpty)
            const Text("No completed timers yet today.", style: TextStyle(color: Colors.grey))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                return ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text("Completed ${item['duration']}"),
                  subtitle: Text("Finished at ${item['completedAt']}"),
                );
              },
            ),
        ],
      ),
    );
  }
}

// 3. STOPWATCH SECTION
class StopwatchSection extends StatefulWidget {
  const StopwatchSection({super.key});

  @override
  State<StopwatchSection> createState() => _StopwatchSectionState();
}

class _StopwatchSectionState extends State<StopwatchSection> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  void _toggleStopwatch() {
    setState(() {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
        _timer?.cancel();
      } else {
        _stopwatch.start();
        _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
          setState(() {});
        });
      }
    });
  }

  void _resetStopwatch() {
    setState(() {
      _stopwatch.reset();
      if (!_stopwatch.isRunning) {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final elapsed = _stopwatch.elapsed;
    final formattedTime =
        "${elapsed.inMinutes.remainder(60).toString().padLeft(2, '0')}:${elapsed.inSeconds.remainder(60).toString().padLeft(2, '0')}.${(elapsed.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0')}";

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            formattedTime,
            style: TextStyle(fontSize: 54, fontWeight: FontWeight.bold, color: primary),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton.large(
                backgroundColor: primary,
                onPressed: _toggleStopwatch,
                child: Icon(_stopwatch.isRunning ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 20),
              IconButton(
                iconSize: 36,
                icon: const Icon(Icons.refresh),
                onPressed: _resetStopwatch,
              ),
            ],
          ),
        ],
      ),
    );
  }
}