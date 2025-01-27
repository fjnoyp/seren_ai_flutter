import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_selected_task_id_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/action_buttons/delete_task_button.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/form/task_selection_fields.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_comments/task_comment_section.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/* === Thoughts on ai generation of create task === 
1) Tasks must be assigned to specific users / projects 
2) Desire to avoid duplication of user / project subset creation logic? 
3) Options:
    A) ai (backend) recalculates subset itself 
    B) client sends the possible selections to backend either fully or as ids 
4) For now: 
    Client will send everything, to avoid need to duplicate logic 

=== Additional Considerations === 
In the future ai (backend) should be independent - this will require refactoring 
SQL logic to a separate shared file to ensure frontend / backend logic remains in sync

We cannot merge sql request logic as client must WATCH data while edge functions 
inherently only READ data. 
We could keep ai as data intake only, and just have 3rd intermediary process insert data
in case where client is not sending the data context  */

final log = Logger('TaskPage');

/// For creating / editing a task
class TaskPage extends HookConsumerWidget {
  final EditablePageMode mode;

  const TaskPage({super.key, required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final curTaskId = ref.watch(curSelectedTaskIdNotifierProvider)!;

    final curTask = ref.watch(taskByIdStreamProvider(curTaskId));

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                isWebVersion
                    ? IconButton(
                        onPressed: () =>
                            ref.read(navigationServiceProvider).pop(true),
                        icon: const Icon(Icons.close),
                      )
                    : const Expanded(child: SizedBox.shrink()),
                const SizedBox(width: 32),
                Text(
                  curTask.isReloading
                      ? 'Saving...'
                      : curTask.hasError
                          ? '𐄂 Error saving'
                          : '✓ All changes saved',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            TaskProjectSelectionField(taskId: curTaskId),
            TaskNameField(taskId: curTaskId),
            const SizedBox(height: 8),

            // ======================
            // ====== SUBITEMS ======
            // ======================
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Column(
                children: [
                  TaskDescriptionSelectionField(
                    taskId: curTaskId,
                    context: context,
                  ),
                  const Divider(),
                  TaskPrioritySelectionField(taskId: curTaskId),
                  const Divider(),
                  TaskStatusSelectionField(taskId: curTaskId),
                  const Divider(),
                  TaskStartDateSelectionField(taskId: curTaskId),
                  TaskDueDateSelectionField(taskId: curTaskId),
                  const Divider(),
                  ReminderMinuteOffsetFromDueDateSelectionField(
                    context: context,
                    taskId: curTaskId,
                    enabled: curTask.value?.dueDate != null,
                  ),
                  const Divider(),
                  TaskParentTaskSelectionField(
                    context: context,
                    taskId: curTaskId,
                    projectId: curTask.value?.parentProjectId ?? '',
                  ),
                  const Divider(),
                  TaskBlockedByTaskSelectionField(
                    context: context,
                    taskId: curTaskId,
                    projectId: curTask.value?.parentProjectId ?? '',
                  ),
                  const Divider(),
                  TaskEstimatedDurationSelectionField(
                    context: context,
                    taskId: curTaskId,
                  ),
                  const Divider(),
                  TaskAssigneesSelectionField(taskId: curTaskId),
                ],
              ),
            ),

            const SizedBox(height: 24),
            TaskCommentSection(curTask.value?.id ?? ''),
            const SizedBox(height: 24),

            if (mode == EditablePageMode.create && !isWebVersion)
              PopScope(
                onPopInvokedWithResult: (_, result) async {
                  if (result != true) {
                    final curTaskId =
                        ref.read(curSelectedTaskIdNotifierProvider)!;
                    ref
                        .read(curSelectedTaskIdNotifierProvider.notifier)
                        .clearTaskId();
                    ref.read(tasksRepositoryProvider).deleteItem(curTaskId);
                  }
                },
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        ref.read(navigationServiceProvider).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
                    ),
                    child: Text(AppLocalizations.of(context)!.createTask),
                  ),
                ),
              ),

            if (isWebVersion) DeleteTaskButton(curTaskId, showLabelText: true),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
