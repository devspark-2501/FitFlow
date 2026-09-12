import 'package:flutter/material.dart';
import 'package:fitflow/components/planner/planner_header.dart';
import 'package:fitflow/components/planner/schedule_timeline.dart';
import '../../widgets/app_drawer.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  // Initial task list state
  final List<ScheduleTask> _scheduleList = [
    ScheduleTask(
      id: "1",
      time: "06:00 AM",
      title: "Wake up & Hydrate",
      category: "Health",
      icon: Icons.wb_sunny_outlined,
      isCompleted: true,
    ),
    ScheduleTask(
      id: "2",
      time: "07:00 AM",
      title: "Morning Run (5km)",
      category: "Workout",
      icon: Icons.directions_run_rounded,
      isCompleted: false,
    ),
    ScheduleTask(
      id: "3",
      time: "08:30 AM",
      title: "Protein Breakfast",
      category: "Diet",
      icon: Icons.restaurant_rounded,
      isCompleted: false,
    ),
  ];

  void _toggleTask(String id) {
    setState(() {
      final task = _scheduleList.firstWhere((element) => element.id == id);
      task.isCompleted = !task.isCompleted;
    });
  }

  void _deleteTask(String id) {
    setState(() {
      _scheduleList.removeWhere((element) => element.id == id);
    });
  }

  void _openAddTaskModal() {
    final titleController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add New Activity",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Task Input Field
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Activity Name (e.g., Evening Yoga)",
                      hintText: "Enter activity title",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Time Picker Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Time: ${selectedTime.format(context)}",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.access_time_rounded),
                        label: const Text("Select Time"),
                        onPressed: () async {
                          final TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (time != null) {
                            setModalState(() {
                              selectedTime = time;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        if (titleController.text.trim().isNotEmpty) {
                          setState(() {
                            _scheduleList.add(
                              ScheduleTask(
                                id: DateTime.now().toString(),
                                time: selectedTime.format(context),
                                title: titleController.text.trim(),
                                category: "Custom",
                                icon: Icons.fitness_center_rounded,
                              ),
                            );
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        "Add To Schedule",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.75),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "FitFlow Planner",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded),
                color: Colors.white,
                onPressed: _openAddTaskModal,
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Component
            PlannerHeader(
              onAddPressed: _openAddTaskModal,
            ),

            const SizedBox(height: 24),

            // Interactive Schedule Timeline
            ScheduleTimeline(
              tasks: _scheduleList,
              onToggleTask: _toggleTask,
              onDeleteTask: _deleteTask,
            ),
          ],
        ),
      ),
    );
  }
}