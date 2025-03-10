import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_assignees_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_minute_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_task_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_text_block_edit_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_date_time_selection_fields.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_priority_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_project_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_status_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_task_name_field.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_user_viewable_projects_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_assignments_service_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/tasks_by_project_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_field_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_assignees_avatars.dart';
import 'package:seren_ai_flutter/services/data/users/providers/task_assigned_users_stream_provider.dart';

// TODO p3: we should ideally pass showLabelWidget down to the parent classes instead
class TaskSelectionField extends ConsumerWidget {
  final TaskFieldEnum field;
  final String taskId;
  final bool isEnabled;
  final bool showLabelWidget;

  const TaskSelectionField(
    this.field, {
    super.key,
    required this.taskId,
    this.isEnabled = true,
    this.showLabelWidget = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (field) {
      TaskFieldEnum.assignees => TaskAssigneesSelectionField(
          context: context,
          taskId: taskId,
          showLabelWidget: showLabelWidget,
        ),
      TaskFieldEnum.status => TaskStatusSelectionField(
          taskId: taskId,
          showLabelWidget: showLabelWidget,
        ),
      TaskFieldEnum.priority => TaskPrioritySelectionField(
          taskId: taskId,
          showLabelWidget: showLabelWidget,
        ),
      TaskFieldEnum.name => TaskNameField(taskId: taskId),
      TaskFieldEnum.dueDate => TaskDueDateSelectionField(taskId: taskId),

      // the fields below are not editable
      TaskFieldEnum.type => const SizedBox.shrink(),
      TaskFieldEnum.createdAt => const SizedBox.shrink(),
    };
  }
}

class TaskProjectSelectionField extends BaseProjectSelectionField {
  final String taskId;

  TaskProjectSelectionField({
    super.key,
    required this.taskId,
  }) : super(
          isEditable: true,
          projectIdProvider: taskByIdStreamProvider(taskId)
              .select((task) => task.value?.parentProjectId),
          selectableProjectsProvider: curUserViewableProjectsProvider,
          updateProject: (ref, project) {
            ref
                .read(curSelectedProjectIdNotifierProvider.notifier)
                .setProjectId(project!.id);
            ref
                .read(tasksRepositoryProvider)
                .updateTaskParentProjectId(taskId, project.id);
          },
        );
}

class TaskStatusSelectionField extends BaseStatusSelectionField {
  final String taskId;

  TaskStatusSelectionField({
    super.key,
    required this.taskId,
    super.showLabelWidget,
  }) : super(
          enabled: true,
          statusProvider: taskByIdStreamProvider(taskId)
              .select((task) => task.value?.status),
          updateStatus: (ref, status) => ref
              .read(tasksRepositoryProvider)
              .updateTaskStatus(taskId, status),
        );
}

class TaskPrioritySelectionField extends BasePrioritySelectionField {
  final String taskId;

  TaskPrioritySelectionField({
    super.key,
    required this.taskId,
    super.showLabelWidget,
  }) : super(
          enabled: true,
          priorityProvider: taskByIdStreamProvider(taskId)
              .select((task) => task.value?.priority),
          updatePriority: (ref, priority) => ref
              .read(tasksRepositoryProvider)
              .updateTaskPriority(taskId, priority),
        );
}

class TaskNameField extends BaseNameField {
  final String taskId;

  TaskNameField({
    super.key,
    required this.taskId,
    super.textStyle,
    super.focusNode,
  }) : super(
          isEditable: true,
          nameProvider: taskByIdStreamProvider(taskId)
              .select((task) => task.value?.name ?? ''),
          updateName: (ref, name) =>
              ref.read(tasksRepositoryProvider).updateTaskName(taskId, name),
        );
}

class TaskDueDateSelectionField extends BaseDueDateSelectionField {
  final String taskId;

  TaskDueDateSelectionField({
    super.key,
    required this.taskId,
  }) : super(
          enabled: true,
          dueDateProvider: taskByIdStreamProvider(taskId)
              .select((task) => task.value?.dueDate),
          updateDueDate: (ref, pickedDateTime) => ref
              .read(tasksRepositoryProvider)
              .updateTaskDueDate(taskId, pickedDateTime),
        );
}

class ReminderMinuteOffsetFromDueDateSelectionField
    extends BaseMinuteSelectionField {
  final String taskId;

  ReminderMinuteOffsetFromDueDateSelectionField({
    super.key,
    required super.enabled,
    required this.taskId,
    required BuildContext context,
  }) : super(
          durationProvider: taskByIdStreamProvider(taskId)
              .select((task) => task.value?.reminderOffsetMinutes),
          updateDuration: (ref, reminder) => ref
              .read(tasksRepositoryProvider)
              .updateTaskReminderOffsetMinutes(taskId, reminder),
          labelWidgetBuilder: (ref) => ref
                      .watch(taskByIdStreamProvider(taskId))
                      .value
                      ?.reminderOffsetMinutes ==
                  null
              ? const Icon(Icons.notifications_off)
              : const Icon(Icons.notifications),
          nullValueString: AppLocalizations.of(context)!.noReminderSet,
          nullOptionString: AppLocalizations.of(context)!.noReminder,
        );
}

class TaskDescriptionSelectionField extends BaseTextBlockEditSelectionField {
  final String taskId;

  TaskDescriptionSelectionField({
    super.key,
    required BuildContext context,
    required this.taskId,
  }) : super(
          isEditable: true,
          hintText: AppLocalizations.of(context)!.description,
          descriptionProvider: taskByIdStreamProvider(taskId)
              .select((task) => task.value?.description ?? ''),
          updateDescription: (ref, description) => ref
              .read(tasksRepositoryProvider)
              .updateTaskDescription(taskId, description),
        );
}

class TaskAssigneesSelectionField extends BaseAssigneesSelectionField {
  final String taskId;

  TaskAssigneesSelectionField({
    super.key,
    required this.taskId,
    required BuildContext context,
    super.showLabelWidget,
    /// use an "+" icon button instead of the "choose assignees" text
    useIconButton = false,
  }) : super(
          enabled: true,
          assigneesProvider: taskAssignedUsersStreamProvider(taskId)
              .select((users) => users.value ?? []),
          projectIdProvider: taskByIdStreamProvider(taskId)
              .select((task) => task.value?.parentProjectId),
          updateAssignees: (ref, assignees) => ref
              .read(taskAssignmentsServiceProvider)
              .updateAssignees(
                  taskId: taskId,
                  assigneeIds: assignees?.map((e) => e.id).toList() ?? []),
          assigneesWidget: (assignees) => assignees.isEmpty
              ? useIconButton
                  ? const Icon(Icons.add)
                  : Text(
                      AppLocalizations.of(context)!.chooseAssignees,
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
              : TaskAssigneesAvatars(
                  taskId,
                  avatarsToShow: 2,
                ),
        );
}

class TaskEstimatedDurationSelectionField extends BaseMinuteSelectionField {
  final String taskId;

  TaskEstimatedDurationSelectionField({
    super.key,
    required this.taskId,
    required BuildContext context,
  }) : super(
          enabled: true,
          durationProvider: taskByIdStreamProvider(taskId)
              .select((task) => task.value?.estimatedDurationMinutes),
          updateDuration: (ref, duration) => ref
              .read(tasksRepositoryProvider)
              .updateTaskEstimatedDurationMinutes(taskId, duration),
          labelWidgetBuilder: (ref) => const Icon(Icons.timer_outlined),
          nullValueString: AppLocalizations.of(context)!.noEstimatedDurationSet,
          nullOptionString: AppLocalizations.of(context)!.noEstimatedDuration,
        );
}

class TaskStartDateSelectionField extends BaseStartDateSelectionField {
  final String taskId;

  TaskStartDateSelectionField({
    super.key,
    required this.taskId,
  }) : super(
          enabled: true,
          startDateTimeProvider: taskByIdStreamProvider(taskId)
              .select((task) => task.value?.startDateTime),
          updateStartDate: (ref, pickedDateTime) => ref
              .read(tasksRepositoryProvider)
              .updateTaskStartDateTime(taskId, pickedDateTime),
        );
}

class TaskPhaseSelectionField extends BaseTaskSelectionField {
  final String taskId;
  final String projectId;
  TaskPhaseSelectionField({
    super.key,
    required this.taskId,
    required this.projectId,
    required BuildContext context,
  }) : super(
          enabled: true,
          taskIdProvider: taskByIdStreamProvider(taskId)
              .select((task) => task.value?.parentTaskId),
          selectableTasksProvider:
              parentTasksByProjectStreamProvider(projectId),
          updateTask: (ref, task) => ref
              .read(tasksRepositoryProvider)
              .updateTaskParentTaskId(taskId, task?.id),
          label: AppLocalizations.of(context)!.phase,
          emptyValueString: AppLocalizations.of(context)!.choosePhase,
        );
}

class TaskBlockedByTaskSelectionField extends BaseTaskSelectionField {
  final String taskId;
  final String projectId;

  TaskBlockedByTaskSelectionField({
    super.key,
    required this.taskId,
    required this.projectId,
    required BuildContext context,
  }) : super(
          enabled: true,
          taskIdProvider: taskByIdStreamProvider(taskId)
              .select((task) => task.value?.blockedByTaskId),
          selectableTasksProvider: tasksByProjectStreamProvider(projectId),
          updateTask: (ref, task) => ref
              .read(tasksRepositoryProvider)
              .updateTaskBlockedByTaskId(taskId, task!.id),
          label: AppLocalizations.of(context)!.blockedByTask,
          emptyValueString: AppLocalizations.of(context)!.selectATask,
        );
}
