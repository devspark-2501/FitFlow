import 'package:flutter/material.dart';

class RingingOverlay extends StatefulWidget {
  final String title;
  final VoidCallback onStop;

  const RingingOverlay({super.key, required this.title, required this.onStop});

  @override
  State<RingingOverlay> createState() => _RingingOverlayState();
}

class _RingingOverlayState extends State<RingingOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          color: Color.lerp(Colors.red.shade900, Colors.red.shade600, _controller.value),
          width: double.infinity,
          height: double.infinity,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.alarm_on, size: 100, color: Colors.white),
                const SizedBox(height: 24),
                Text(
                  widget.title,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),
                const Text(
                  "TIME IS UP!",
                  style: TextStyle(fontSize: 20, color: Colors.white70, letterSpacing: 2),
                ),
                const SizedBox(height: 60),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red.shade900,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  ),
                  onPressed: widget.onStop,
                  child: const Text(
                    "STOP ALARM",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}