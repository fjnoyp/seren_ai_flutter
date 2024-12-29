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
            margin: const EdgeInsets.all(50),
            decoration: BoxDecoration(
              border: Border.all(width: 3),
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
      final mainTaskName = [ganttTask.joinedTask.task.name];
      final subTaskNames = ganttTask.children
          .map((subTask) => [subTask.joinedTask.task.name])
          .toList();

      return [mainTaskName, ...subTaskNames];
    }).toList();

    // TODO: reconcile GanttTask and GanttEvent types
    // We will add the fields of GanttTask into the GanttEvent
    // and allow Gantt Event to handle nesting
    // Then we will create a sub class of it for the acutal Task information to be displayed (TaskModel / JoinedTaskModel)
    // Goal is to allow proper separation of UI logic and our task specific logic
    final ganttEvents = ganttTasks.expand((ganttTask) {
      final mainTaskEvent = GanttEvent(
        title: ganttTask.joinedTask.task.name,
        startDate: ganttTask.joinedTask.task.startDateTime ?? DateTime.now(),
        endDate: ganttTask.joinedTask.task.dueDate ?? DateTime.now(),
        color: ganttTask.color,
      );
      final subTaskEvents = ganttTask.children.map((subTask) {
        return GanttEvent(
          title: subTask.joinedTask.task.name,
          startDate: subTask.joinedTask.task.startDateTime ?? DateTime.now(),
          endDate: subTask.joinedTask.task.dueDate ?? DateTime.now(),
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
