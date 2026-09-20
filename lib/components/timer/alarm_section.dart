import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../services/alarm_db_service.dart';

class AlarmSection extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final Function(bool, String) onRingingChanged;

  const AlarmSection({
    super.key,
    required this.audioPlayer,
    required this.onRingingChanged,
  });

  @override
  State<AlarmSection> createState() => _AlarmSectionState();
}

class _AlarmSectionState extends State<AlarmSection> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Map<String, dynamic>> _savedAlarms = [];
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
    _startChecker();
  }

  Future<void> _loadAlarms() async {
    final data = await AlarmDbService.instance.getAlarms();
    setState(() => _savedAlarms = data);
  }

  void _startChecker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = TimeOfDay.now();
      for (var alarm in _savedAlarms) {
        if (alarm['isEnabled'] == 1 &&
            alarm['hour'] == now.hour &&
            alarm['minute'] == now.minute) {
          _triggerAlarm(alarm['label']);
          _toggleAlarm(alarm['id'], false);
          break;
        }
      }
    });
  }

  void _triggerAlarm(String label) async {
    await widget.audioPlayer.setReleaseMode(ReleaseMode.loop);
    await widget.audioPlayer.play(AssetSource('alarm_sound.mp3'));
    widget.onRingingChanged(true, label);
  }

  Future<void> _addNewAlarm() async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) {
      await AlarmDbService.instance.insertAlarm("Alarm", time.hour, time.minute);
      _loadAlarms();
    }
  }

  Future<void> _toggleAlarm(int id, bool val) async {
    await AlarmDbService.instance.updateAlarmStatus(id, val);
    _loadAlarms();
  }

  Future<void> _deleteAlarm(int id) async {
    await AlarmDbService.instance.deleteAlarm(id);
    _loadAlarms();
  }

  String _formatTimeOfDay(int hour, int minute) {
    final time = TimeOfDay(hour: hour, minute: minute);
    return time.format(context);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Saved Alarms", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton.filled(
                onPressed: _addNewAlarm,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _savedAlarms.isEmpty
                ? const Center(child: Text("No saved alarms. Tap + to create one."))
                : ListView.builder(
              itemCount: _savedAlarms.length,
              itemBuilder: (context, index) {
                final alarm = _savedAlarms[index];
                final isEnabled = alarm['isEnabled'] == 1;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    title: Text(
                      _formatTimeOfDay(alarm['hour'], alarm['minute']),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isEnabled ? primary : Colors.grey,
                      ),
                    ),
                    subtitle: Text(alarm['label']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: isEnabled,
                          onChanged: (val) => _toggleAlarm(alarm['id'], val),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteAlarm(alarm['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}