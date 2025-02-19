import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/task_filter_option_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_overview/task_search_modal.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_selected_task_id_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/tasks_by_parent_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/action_buttons/delete_task_button.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/budget/task_budget_section.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/form/task_selection_fields.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/inline_task_creation_widget.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_comments/task_comment_section.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/tasks_list_tiles_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_tag.dart';
import 'package:seren_ai_flutter/widgets/common/debug_mode_provider.dart';

final log = Logger('TaskPage');

/// For creating / editing a task
class WebTaskPage extends ConsumerWidget {
  const WebTaskPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curTaskId = ref.watch(curSelectedTaskIdNotifierProvider) ?? '';
    final isPhase =
        ref.watch(taskByIdStreamProvider(curTaskId)).value?.isPhase ?? false;

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
                    if (isPhase) Tab(text: AppLocalizations.of(context)?.tasks),
                    Tab(text: AppLocalizations.of(context)?.comments),
                    if (isDebugMode) const Tab(text: 'Budget'),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TabBarView(
                      children: [
                        if (isPhase) _TasksFromPhaseSection(phaseId: curTaskId),
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

class _TasksFromPhaseSection extends ConsumerWidget {
  const _TasksFromPhaseSection({required this.phaseId});

  final String phaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksByParentStreamProvider(phaseId));
    final labelStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            AppLocalizations.of(context)?.addTasks ?? 'Add Tasks',
            style: labelStyle,
          ),
        ),
        Expanded(
          child: TaskSearchModal(
            autoFocus: false,
            onTapOption: (taskId) => ref
                .read(tasksRepositoryProvider)
                .updateTaskParentTaskId(taskId, phaseId),
            hiddenFilters: const [TaskFilterOption.type],
            additionalFilter: (task) =>
                task.isPhase == false && task.parentTaskId == null,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppLocalizations.of(context)?.phaseTasks ?? 'Phase Tasks',
                style: labelStyle,
              ),
            ),
          ],
        ),
        Expanded(
          child: Column(
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: TasksListTilesView(
                    watchedTasks: tasks,
                    filterCondition: null,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: InlineTaskCreationButton(
                  // additionalFields: const [TaskFieldEnum.assignees],
                  initialParentTaskId: phaseId,
                ),
              ),
            ],
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
    if (task.value == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isPhase = task.value?.isPhase ?? false;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16),
            child: Row(
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
                const Expanded(child: SizedBox.shrink()),
                isPhase ? TaskTag.phase() : TaskTag.task(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TaskProjectSelectionField(taskId: taskId),
                if (!isPhase)
                  TaskPhaseSelectionField(
                    context: context,
                    taskId: taskId,
                    projectId: task.value?.parentProjectId ?? '',
                  ),
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
                            TaskStartDateSelectionField(taskId: taskId),
                            TaskDueDateSelectionField(taskId: taskId),
                            if (!isPhase)
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
                            if (!isPhase)
                              TaskStatusSelectionField(taskId: taskId),
                            if (!isPhase)
                              TaskBlockedByTaskSelectionField(
                                context: context,
                                taskId: taskId,
                                projectId: task.value?.parentProjectId ?? '',
                              ),
                            TaskEstimatedDurationSelectionField(
                              context: context,
                              taskId: taskId,
                            ),
                            TaskAssigneesSelectionField(
                              context: context,
                              taskId: taskId,
                            ),
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
        ],
      ),
    );
  }
}
