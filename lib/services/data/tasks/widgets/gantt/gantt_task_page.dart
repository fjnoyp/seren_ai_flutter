import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/gantt_task_snp.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/gantt_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/inline_creation/inline_task_creation_button.dart';

class GanttTaskPage extends ConsumerWidget {
  const GanttTaskPage({super.key});

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
            child: const GanttChart(projectId: null),
          ),
        )
      ],
    ));
  }
}
class GanttChart extends HookConsumerWidget {
  const GanttChart({super.key, required this.projectId});

  /// The project id to filter the tasks by.
  ///
  /// If null, all tasks will be shown.
  final String? projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewType = useState(GanttViewType.week);
    final horizontalScrollController = useState<ScrollController?>(null);
    final verticalScrollController = useState<ScrollController?>(null);

    // Initialize the controller
    useEffect(() {
      horizontalScrollController.value = ScrollController();
      return () => horizontalScrollController.value?.dispose();
    }, []);

    // Center scroll when view type changes
    // TODO p3: change this to track the current day
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (horizontalScrollController.value?.hasClients == true) {
          final position = horizontalScrollController.value!.position;
          final maxScroll = position.maxScrollExtent;
          final middlePosition = maxScroll / 2;
          horizontalScrollController.value!.jumpTo(middlePosition);
        }
      });
      return null;
    }, [viewType.value]);

    // Initialize the controller
    useEffect(() {
      verticalScrollController.value = ScrollController();
      return () => verticalScrollController.value?.dispose();
    }, []);

    final ganttTasks = ref.watch(ganttTaskProvider(projectId)).tasks;

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
          color:
              ganttTask.color.withAlpha(180), // make slightly more transparent
        );
      });
      return [mainTaskEvent, ...subTaskEvents];
    }).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Inline phase creation
            InlineTaskCreationButton(
              isPhase: true,
              onPressed: () => Future.microtask(() {
                if (verticalScrollController.value != null) {
                  verticalScrollController.value!.jumpTo(0);
                }
              }),
            ),
            const SizedBox(width: 8),
            // Inline task creation
            InlineTaskCreationButton(
              onPressed: () => Future.microtask(() {
                if (verticalScrollController.value != null) {
                  verticalScrollController.value!.jumpTo(0);
                }
              }),
            ),
          ],
        ),
        Expanded(
          child: GanttView(
            staticHeadersValues: ['Task Name'],
            staticRowsValues: staticRowsValues,
            events: ganttEvents,
            viewType: viewType.value,
            horizontalScrollController: horizontalScrollController.value,
            verticalScrollController: verticalScrollController.value,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SegmentedButton<GanttViewType>(
            segments: [
              ButtonSegment(
                value: GanttViewType.day,
                icon: const Icon(Icons.today_outlined),
                label: Text(AppLocalizations.of(context)!.day),
              ),
              ButtonSegment(
                value: GanttViewType.week,
                icon: const Icon(Icons.date_range_outlined),
                label: Text(AppLocalizations.of(context)!.week),
              ),
              ButtonSegment(
                value: GanttViewType.month,
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(AppLocalizations.of(context)!.month),
              ),
            ],
            selected: {viewType.value},
            onSelectionChanged: (selected) {
              viewType.value = selected.first;
            },
          ),
        ),
      ],
    );
  }
}
