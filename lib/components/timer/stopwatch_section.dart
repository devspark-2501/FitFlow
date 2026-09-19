import 'dart:async';
import 'package:flutter/material.dart';

class StopwatchSection extends StatefulWidget {
  const StopwatchSection({super.key});

  @override
  State<StopwatchSection> createState() => _StopwatchSectionState();
}

class _StopwatchSectionState extends State<StopwatchSection> {
  Timer? _timer;
  int _milliseconds = 0;
  bool _isRunning = false;
  final List<String> _laps = [];

  void _start() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() => _milliseconds += 10);
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _reset() {
    _pause();
    setState(() {
      _milliseconds = 0;
      _laps.clear();
    });
  }

  void _addLap() {
    if (_isRunning) {
      setState(() {
        _laps.insert(0, _formatTime(_milliseconds));
      });
    }
  }

  String _formatTime(int ms) {
    final mins = ((ms ~/ 60000) % 60).toString().padLeft(2, '0');
    final secs = ((ms ~/ 1000) % 60).toString().padLeft(2, '0');
    final hundredths = ((ms % 1000) ~/ 10).toString().padLeft(2, '0');
    return "$mins:$secs.$hundredths";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            _formatTime(_milliseconds),
            style: TextStyle(fontSize: 54, fontWeight: FontWeight.bold, color: primary),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                backgroundColor: primary,
                onPressed: _isRunning ? _pause : _start,
                child: Icon(_isRunning ? Icons.pause : Icons.play_arrow, color: Colors.white),
              ),
              const SizedBox(width: 16),
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.flag_outlined),
                onPressed: _isRunning ? _addLap : null,
              ),
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.refresh),
                onPressed: _reset,
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("Recorded Laps & History", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _laps.isEmpty
                ? const Center(child: Text("No laps recorded", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              itemCount: _laps.length,
              itemBuilder: (context, index) {
                return ListTile(
                  dense: true,
                  leading: Text("Lap ${_laps.length - index}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text(_laps[index], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}