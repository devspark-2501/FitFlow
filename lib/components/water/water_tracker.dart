import 'dart:convert';
import 'package:fitflow/services/water_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterTracker extends StatefulWidget {
  final int dailyGoalMl;
  final VoidCallback onResetGoal;

  const WaterTracker({
    super.key,
    required this.dailyGoalMl,
    required this.onResetGoal,
  });

  @override
  State<WaterTracker> createState() => _WaterTrackerState();
}

class _WaterTrackerState extends State<WaterTracker> {
  int _currentIntakeMl = 0;
  List<Map<String, String>> _todayLogs = [];
  Map<String, int> _historyData = {};

  bool _isLoading = true;
  String? _userId;
  int _selectedFilterDays = 7;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndLogs();
  }

  Future<void> _loadUserDataAndLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('userData');

    if (userString != null) {
      final userData = jsonDecode(userString);
      _userId = userData['_id'] ?? userData['id'];
      if (_userId != null) {
        await _fetchTodayAndHistoryLogs();
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchTodayAndHistoryLogs() async {
    if (_userId == null) return;

    final todayData = await WaterService.fetchTodayWaterLogs(_userId!);
    if (todayData != null && todayData['success'] == true && mounted) {
      final List rawLogs = todayData['logs'] ?? [];
      _currentIntakeMl = todayData['totalIntake'] ?? 0;
      _todayLogs = rawLogs.map((item) {
        final timestamp = DateTime.parse(item['timestamp']);
        final hour = timestamp.hour == 0 || timestamp.hour == 12 ? 12 : timestamp.hour % 12;
        final period = timestamp.hour >= 12 ? 'PM' : 'AM';
        final minute = timestamp.minute.toString().padLeft(2, '0');
        return {
          'amount': '+${item['amount']} ml',
          'time': '$hour:$minute $period',
        };
      }).toList();
    }

    final history = await WaterService.fetchWaterHistory(_userId!, _selectedFilterDays);
    if (history != null && history['success'] == true && mounted) {
      final Map<String, dynamic> rawHistory = history['data'] ?? {};
      _historyData = rawHistory.map((key, value) => MapEntry(key, (value as num).toInt()));
    }

    if (mounted) setState(() {});
  }

  Future<void> _addWater(int amount) async {
    if (amount <= 0 || _userId == null) return;

    final success = await WaterService.addWaterLog(_userId!, amount);
    if (success) {
      await _fetchTodayAndHistoryLogs();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save water log to server')),
      );
    }
  }

  void _showCustomIntakeDialog(Color primaryColor) {
    final TextEditingController customController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Custom Amount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: customController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Water Intake (ml)',
                  suffixText: 'ml',
                  prefixIcon: Icon(Icons.edit, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final int? enteredAmount = int.tryParse(customController.text);
                    if (enteredAmount != null && enteredAmount > 0) {
                      _addWater(enteredAmount);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Add Intake',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryColor = Colors.blueAccent;
    final int remainingMl = (widget.dailyGoalMl - _currentIntakeMl).clamp(0, widget.dailyGoalMl);
    final double progress = (_currentIntakeMl / widget.dailyGoalMl).clamp(0.0, 1.0);

    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. Progress Dial
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryColor.withOpacity(0.15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 12,
                        backgroundColor: primaryColor.withOpacity(0.12),
                        color: primaryColor,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '$_currentIntakeMl / ${widget.dailyGoalMl} ml',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    remainingMl > 0
                        ? 'Just $remainingMl ml remaining to hit target!'
                        : '🎉 Goal achieved! Great job!',
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Log Quick Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryColor.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Log Intake',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAddButton(150, 'Glass', Icons.local_drink, primaryColor, () => _addWater(150)),
                    _buildAddButton(250, 'Cup', Icons.water_drop, primaryColor, () => _addWater(250)),
                    _buildAddButton(500, 'Bottle', Icons.wine_bar, primaryColor, () => _addWater(500)),
                    _buildAddButton(0, 'Custom', Icons.edit, primaryColor, () => _showCustomIntakeDialog(primaryColor)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Hydration Graph
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryColor.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hydration Progress',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Row(
                      children: [
                        _buildFilterChip(7, '7 Days'),
                        const SizedBox(width: 6),
                        _buildFilterChip(30, '30 Days'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildBarChart(primaryColor),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. Date-wise list
          if (_historyData.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryColor.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date-Wise History',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _historyData.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final dateStr = _historyData.keys.elementAt(index);
                      final intake = _historyData[dateStr] ?? 0;
                      final double liters = intake / 1000.0;
                      final bool metTarget = intake >= widget.dailyGoalMl;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                metTarget ? Icons.check_circle : Icons.water_drop,
                                color: metTarget ? Colors.green : primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                dateStr,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Text(
                            '${liters.toStringAsFixed(1)} L (${intake} ml)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: metTarget ? Colors.green : theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int days, String label) {
    final isSelected = _selectedFilterDays == days;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.black87)),
      selected: isSelected,
      selectedColor: Colors.blueAccent,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _selectedFilterDays = days;
            _isLoading = true;
          });
          _fetchTodayAndHistoryLogs().then((_) {
            if (mounted) setState(() => _isLoading = false);
          });
        }
      },
    );
  }

  Widget _buildBarChart(Color primaryColor) {
    final todayStr = WaterService.getTodayDateString();

    // Use history data if non-empty, otherwise populate dynamic map with today's intake
    final Map<String, int> chartMap = Map.from(_historyData);
    if (!chartMap.containsKey(todayStr) || (chartMap[todayStr] ?? 0) < _currentIntakeMl) {
      chartMap[todayStr] = _currentIntakeMl;
    }

    final entries = chartMap.entries.toList();
    final maxMl = entries.map((e) => e.value).fold<int>(widget.dailyGoalMl, (a, b) => a > b ? a : b);

    return SizedBox(
      height: 140,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: entries.map((entry) {
          final double barHeightRatio = (entry.value / maxMl).clamp(0.08, 1.0);
          final bool targetReached = entry.value >= widget.dailyGoalMl;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${(entry.value / 1000).toStringAsFixed(1)}L',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _selectedFilterDays == 7 ? 18 : 6,
                height: 85 * barHeightRatio,
                decoration: BoxDecoration(
                  color: targetReached ? Colors.green : primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                entry.key.length >= 10 ? entry.key.substring(5) : entry.key,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAddButton(
      int amount,
      String label,
      IconData icon,
      Color primaryColor,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryColor, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            amount > 0 ? '+$amount ml' : label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}