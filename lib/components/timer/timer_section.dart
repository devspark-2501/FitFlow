import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';

class TimerSection extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final Function(bool, String) onRingingChanged;

  const TimerSection({
    super.key,
    required this.audioPlayer,
    required this.onRingingChanged,
  });

  @override
  State<TimerSection> createState() => _TimerSectionState();
}

class _TimerSectionState extends State<TimerSection> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Timer? _timer;
  int _initialSeconds = 60;
  int _remainingSeconds = 60;
  bool _isRunning = false;

  void _startTimer() {
    if (_remainingSeconds <= 0) return;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _triggerAlarm();
      }
    });
  }

  void _triggerAlarm() async {
    _pauseTimer();
    await widget.audioPlayer.setReleaseMode(ReleaseMode.loop);
    await widget.audioPlayer.play(AssetSource('alarm_sound.mp3'));
    widget.onRingingChanged(true, "Timer Finished");
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _pauseTimer();
    setState(() => _remainingSeconds = _initialSeconds);
  }

  void _showTimerPicker() {
    if (_isRunning) return;
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
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
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
    super.build(context);
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _showTimerPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: primary.withOpacity(0.2), width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: primary),
                  ),
                  const SizedBox(height: 8),
                  Text("Tap to change duration", style: TextStyle(color: primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton.large(
                backgroundColor: primary,
                onPressed: _isRunning ? _pauseTimer : _startTimer,
                child: Icon(_isRunning ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 40),
              ),
              const SizedBox(width: 24),
              IconButton(
                iconSize: 40,
                icon: const Icon(Icons.refresh),
                onPressed: _resetTimer,
              ),
            ],
          ),
        ],
      ),
    );
  }
}