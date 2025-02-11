import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/tasks_by_project_stream_provider.dart';

class ProjectTasksSearchAnchor extends HookConsumerWidget {
  const ProjectTasksSearchAnchor({
    super.key,
    required this.onTapOption,
    this.hidePhases = false,
    this.tasksFilter,
  });

  final void Function(String) onTapOption;
  final bool hidePhases;
  final bool Function(TaskModel)? tasksFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curProjectId = ref.watch(curSelectedProjectIdNotifierProvider);
    if (curProjectId == null) {
      return const SizedBox.shrink();
    }
    final projectTasks =
        ref.watch(tasksByProjectStreamProvider(curProjectId)).value ?? [];

    if (hidePhases) projectTasks.removeWhere((e) => e.isPhase);

    projectTasks.retainWhere(tasksFilter ?? (_) => true);

    projectTasks.sort((a, b) =>
        a.updatedAt?.isAfter(b.updatedAt ?? DateTime.now()) ?? false ? 1 : -1);

    final controller = useSearchController();

    return SearchAnchor.bar(
      searchController: controller,
      barLeading: const SizedBox.shrink(),
      barTrailing: const [Icon(Icons.search)],
      viewLeading: const SizedBox.shrink(),
      barHintText: 'Search tasks...',
      barElevation: const WidgetStatePropertyAll(0),
      barShape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      viewShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      suggestionsBuilder: (context, controller) {
        if (controller.text.isEmpty) {
          return projectTasks.take(5).map(
                (e) => _TaskOptionTile(
                    task: e, controller: controller, onTapOption: onTapOption),
              );
        }

        return projectTasks
            .where((e) =>
                e.name.toLowerCase().contains(controller.text.toLowerCase()))
            .map((e) => _TaskOptionTile(
                  task: e,
                  controller: controller,
                  onTapOption: onTapOption,
                ))
            .toList();
      },
    );
  }
}

class _TaskOptionTile extends StatelessWidget {
  const _TaskOptionTile({
    required this.task,
    required this.controller,
    required this.onTapOption,
  });

  final TaskModel task;
  final SearchController controller;
  final void Function(String) onTapOption;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.name),
      onTap: () {
        onTapOption(task.id);
        controller.closeView(task.name);
      },
    );
  }
}
