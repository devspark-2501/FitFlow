import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AlarmSection extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const AlarmSection({super.key, required this.audioPlayer});

  @override
  State<AlarmSection> createState() => _AlarmSectionState();
}

class _AlarmSectionState extends State<AlarmSection> {
  TimeOfDay _alarmTime = const TimeOfDay(hour: 5, minute: 30);
  bool _isEnabled = false;
  bool _isRinging = false;
  Timer? _ticker;

  final List<Map<String, String>> _alarmHistory = [
    {'time': '05:30 AM', 'date': 'Yesterday', 'status': 'Dismissed'},
    {'time': '04:50 AM', 'date': 'Today', 'status': 'Set'},
  ];

  @override
  void initState() {
    super.initState();
    _startRealtimeChecker();
  }

  void _startRealtimeChecker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isEnabled || _isRinging) return;
      final now = TimeOfDay.now();
      if (now.hour == _alarmTime.hour && now.minute == _alarmTime.minute) {
        _triggerAlarm();
      }
    });
  }

  void _triggerAlarm() async {
    setState(() => _isRinging = true);
    await widget.audioPlayer.setReleaseMode(ReleaseMode.loop);
    await widget.audioPlayer.play(AssetSource('alarm_sound.mp3'));
  }

  void _stopAlarm() async {
    await widget.audioPlayer.stop();
    setState(() {
      _isRinging = false;
      _isEnabled = false;
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final selected = await showTimePicker(
                            context: context,
                            initialTime: _alarmTime,
                          );
                          if (selected != null) {
                            setState(() {
                              _alarmTime = selected;
                              _alarmHistory.insert(0, {
                                'time': selected.format(context),
                                'date': 'Today',
                                'status': 'Configured'
                              });
                            });
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Workout Alarm", style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              _alarmTime.format(context),
                              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: primary),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isEnabled,
                        activeColor: primary,
                        onChanged: (val) {
                          setState(() => _isEnabled = val);
                        },
                      ),
                    ],
                  ),
                  if (_isRinging) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: _stopAlarm,
                        icon: const Icon(Icons.alarm_off, color: Colors.white),
                        label: const Text("DISMISS ALARM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("Alarm History & Logs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _alarmHistory.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final item = _alarmHistory[index];
              return ListTile(
                leading: const Icon(Icons.alarm, color: Colors.blue),
                title: Text(item['time']!),
                subtitle: Text("${item['date']} • ${item['status']}"),
              );
            },
          ),
        ],
      ),
    );
  }
}