import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/gantt_task_snp.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/gantt_view.dart';

class TaskGanttPage extends ConsumerWidget {
  const TaskGanttPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              border: Border.all(width: 0),
            ),
            child: gantt(ref),
          ),
        )
      ],
    ));
  }

  Widget gantt(WidgetRef ref) {
    // Load in current viewable tasks, then convert into the gantt chart data format

    final ganttTasks = ref.watch(ganttTaskProvider).tasks;

    final staticRowsValues = ganttTasks.expand((ganttTask) {
      final mainTaskName = [ganttTask.task.name];
      final subTaskNames =
          ganttTask.children.map((subTask) => [subTask.task.name]).toList();

      return [mainTaskName, ...subTaskNames];
    }).toList();

    // TODO: reconcile GanttTask and GanttEvent types
    // We will add the fields of GanttTask into the GanttEvent
    // and allow Gantt Event to handle nesting
    // Then we will create a sub class of it for the acutal Task information to be displayed (TaskModel / taskModel)
    // Goal is to allow proper separation of UI logic and our task specific logic
    final ganttEvents = ganttTasks.expand((ganttTask) {
      final mainTaskEvent = GanttEvent(
        title: ganttTask.task.name,
        startDate: ganttTask.task.startDateTime,
        endDate: ganttTask.task.dueDate,
        color: ganttTask.color,
      );

      final subTaskEvents = ganttTask.children.map((subTask) {
        return GanttEvent(
          title: subTask.task.name,
          startDate: subTask.task.startDateTime,
          endDate: subTask.task.dueDate,
          color: ganttTask.color
              .withOpacity(0.7), // make slightly more transparent
        );
      });
      return [mainTaskEvent, ...subTaskEvents];
    }).toList();

    return GanttView(
        staticHeadersValues: ['Task Name'],
        staticRowsValues: staticRowsValues,
        events: ganttEvents);
  }
}
