import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_selected_task_id_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/action_buttons/delete_task_button.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/budget/task_budget_section.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/form/task_selection_fields.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_comments/task_comment_section.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/widgets/common/debug_mode_provider.dart';

final log = Logger('TaskPage');

/// For creating / editing a task
class WebTaskPage extends ConsumerWidget {
  final EditablePageMode mode;

  const WebTaskPage({super.key, required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curTaskId = ref.watch(curSelectedTaskIdNotifierProvider) ?? '';

    final isDebugMode = ref.watch(isDebugModeSNP);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _TaskInfoDisplay(taskId: curTaskId)),
        const VerticalDivider(),
        Expanded(
          flex: 2,
          child: DefaultTabController(
            length: isDebugMode ? 2 : 1,
            child: Column(
              children: [
                TabBar(
                  tabs: [
                    Tab(text: AppLocalizations.of(context)?.comments),
                    if (isDebugMode) const Tab(text: 'Budget'),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TabBarView(
                      children: [
                        TaskCommentSection(curTaskId),
                        if (isDebugMode) TaskBudgetSection(curTaskId),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskInfoDisplay extends ConsumerWidget {
  const _TaskInfoDisplay({required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final task = ref.watch(taskByIdStreamProvider(taskId));

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () =>
                      ref.read(navigationServiceProvider).pop(true),
                  icon: const Icon(Icons.close),
                ),
                const SizedBox(width: 32),
                Text(
                  task.isReloading
                      ? AppLocalizations.of(context)!.saving
                      : task.hasError
                          ? AppLocalizations.of(context)!.errorSaving
                          : AppLocalizations.of(context)!.allChangesSaved,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            TaskProjectSelectionField(taskId: taskId),
            TaskNameField(taskId: taskId),
            const SizedBox(height: 8),

            // ======================
            // ====== SUBITEMS ======
            // ======================
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TaskPrioritySelectionField(taskId: taskId),
                        TaskStatusSelectionField(taskId: taskId),
                        TaskStartDateSelectionField(taskId: taskId),
                        TaskDueDateSelectionField(taskId: taskId),
                        ReminderMinuteOffsetFromDueDateSelectionField(
                          context: context,
                          taskId: taskId,
                          enabled: task.value?.dueDate != null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TaskParentTaskSelectionField(
                          context: context,
                          taskId: taskId,
                          projectId: task.value?.parentProjectId ?? '',
                        ),
                        TaskBlockedByTaskSelectionField(
                          context: context,
                          taskId: taskId,
                          projectId: task.value?.parentProjectId ?? '',
                        ),
                        TaskEstimatedDurationSelectionField(
                          context: context,
                          taskId: taskId,
                        ),
                        TaskAssigneesSelectionField(taskId: taskId),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            TaskDescriptionSelectionField(taskId: taskId, context: context),
            const SizedBox(height: 16),

            DeleteTaskButton(taskId, showLabelText: true),
          ],
        ),
      ),
    );
  }
}
