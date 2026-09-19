import 'package:fitflow/components/timer/alarm_section.dart';
import 'package:fitflow/components/timer/stopwatch_section.dart';
import 'package:fitflow/components/timer/timer_section.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

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