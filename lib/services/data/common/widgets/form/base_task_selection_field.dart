import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/selection_field.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';

class BaseTaskSelectionField extends ConsumerWidget {
  final bool enabled;
  final ProviderListenable<String?> taskIdProvider;
  final AutoDisposeStreamProvider<List<TaskModel>?> selectableTasksProvider;
  final Function(WidgetRef, TaskModel?) updateTask;
  final String? label;

  const BaseTaskSelectionField({
    super.key,
    required this.enabled,
    required this.taskIdProvider,
    required this.selectableTasksProvider,
    required this.updateTask,
    this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskId = ref.watch(taskIdProvider);
    final selectableTasksAsync = ref.watch(selectableTasksProvider);

    // Use FutureBuilder to handle the async task loading
    return FutureBuilder<TaskModel?>(
      // Fetch task whenever ID changes
      future: taskId != null
          ? ref.read(tasksRepositoryProvider).getById(taskId)
          : Future.value(null),
      builder: (context, taskSnapshot) {
        // Handle loading states
        if (taskSnapshot.connectionState == ConnectionState.waiting ||
            selectableTasksAsync.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle error states
        if (taskSnapshot.hasError) {
          return Text('Error loading task: ${taskSnapshot.error}');
        }
        if (selectableTasksAsync.hasError) {
          return Text('Error loading tasks: ${selectableTasksAsync.error}');
        }

        final task = taskSnapshot.data;
        final selectableTasks = selectableTasksAsync.valueOrNull ?? [];

        return enabled
            ? AnimatedModalSelectionField<TaskModel>(
                labelWidget: SizedBox(
                  width: 60,
                  child: Text(
                    label ?? AppLocalizations.of(context)!.task,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                validator: (_) => null,
                valueToString: (task) =>
                    task?.name ?? AppLocalizations.of(context)!.selectATask,
                enabled: enabled,
                value: task,
                options: selectableTasks,
                onValueChanged: (ref, task) => updateTask(ref, task),
                isValueRequired: false,
              )
            : Text(task?.name ?? '');
      },
    );
  }
}
