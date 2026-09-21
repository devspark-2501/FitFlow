import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../components/timer/alarm_section.dart';
import '../../components/timer/stopwatch_section.dart';
import '../../components/timer/timer_section.dart';
import '../../components/timer/ringing_overlay.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRinging = false;
  String _ringingTitle = "";
  Timer? _snoozeTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _handleRinging(bool ringing, String title) {
    setState(() {
      _isRinging = ringing;
      _ringingTitle = title;
    });
  }

  void _stopRinging() async {
    await _audioPlayer.stop();
    setState(() {
      _isRinging = false;
    });
  }

  void _snoozeAlarm() async {
    await _audioPlayer.stop();
    setState(() {
      _isRinging = false;
    });

    _snoozeTimer?.cancel();
    _snoozeTimer = Timer(const Duration(minutes: 5), () async {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('alarm_sound.mp3'));
      _handleRinging(true, "$_ringingTitle (Snoozed)");
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Snoozed for 5 minutes")),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioPlayer.dispose();
    _snoozeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
            title: const Text("Timer & Alarm"),
            bottom: TabBar(
              controller: _tabController,
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
              TimerSection(audioPlayer: _audioPlayer, onRingingChanged: _handleRinging),
              const StopwatchSection(),
              AlarmSection(audioPlayer: _audioPlayer, onRingingChanged: _handleRinging),
            ],
          ),
        ),
        if (_isRinging)
          RingingOverlay(
            title: _ringingTitle,
            onStop: _stopRinging,
            onSnooze: _snoozeAlarm,
          ),
      ],
    );
  }
}