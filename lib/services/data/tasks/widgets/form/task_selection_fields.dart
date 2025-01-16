import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_assignees_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_minute_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_text_block_edit_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_due_date_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_priority_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_project_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_status_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_task_name_field.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_user_viewable_projects_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_assignments_service_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/users/providers/users_in_task_stream_provider.dart';

class TaskProjectSelectionField extends BaseProjectSelectionField {
  final String taskId;

  TaskProjectSelectionField({
    super.key,
    required super.isEditable,
    required this.taskId,
  }) : super(
          projectIdProvider: taskStreamProvider(taskId)
              .select((task) => task.value?.parentProjectId),
          selectableProjectsProvider: curUserViewableProjectsProvider,
          updateProject: (ref, project) => ref
              .read(tasksRepositoryProvider)
              .updateTaskParentProjectId(taskId, project!.id),
        );
}

class TaskStatusSelectionField extends BaseStatusSelectionField {
  final String taskId;

  TaskStatusSelectionField({
    super.key,
    required super.enabled,
    required this.taskId,
  }) : super(
          statusProvider:
              taskStreamProvider(taskId).select((task) => task.value?.status),
          updateStatus: (ref, status) => ref
              .read(tasksRepositoryProvider)
              .updateTaskStatus(taskId, status),
        );
}

class TaskPrioritySelectionField extends BasePrioritySelectionField {
  final String taskId;

  TaskPrioritySelectionField({
    super.key,
    required super.enabled,
    required this.taskId,
  }) : super(
          priorityProvider:
              taskStreamProvider(taskId).select((task) => task.value?.priority),
          updatePriority: (ref, priority) => ref
              .read(tasksRepositoryProvider)
              .updateTaskPriority(taskId, priority),
        );
}

class TaskNameField extends BaseNameField {
  final String taskId;

  TaskNameField({
    super.key,
    required super.isEditable,
    required this.taskId,
  }) : super(
          nameProvider: taskStreamProvider(taskId)
              .select((task) => task.value?.name ?? ''),
          updateName: (ref, name) =>
              ref.read(tasksRepositoryProvider).updateTaskName(taskId, name),
        );
}

class TaskDueDateSelectionField extends BaseDueDateSelectionField {
  final String taskId;

  TaskDueDateSelectionField({
    super.key,
    required super.enabled,
    required this.taskId,
  }) : super(
          dueDateProvider:
              taskStreamProvider(taskId).select((task) => task.value?.dueDate),
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
  }) : super(
          reminderProvider: taskStreamProvider(taskId)
              .select((task) => task.value?.reminderOffsetMinutes),
          updateReminder: (ref, reminder) => ref
              .read(tasksRepositoryProvider)
              .updateTaskReminderOffsetMinutes(taskId, reminder),
          labelWidgetBuilder: (ref) => ref
                      .watch(taskStreamProvider(taskId))
                      .value
                      ?.reminderOffsetMinutes ==
                  null
              ? const Icon(Icons.notifications_off)
              : const Icon(Icons.notifications),
        );
}

class TaskDescriptionSelectionField extends BaseTextBlockEditSelectionField {
  final String taskId;

  TaskDescriptionSelectionField({
    super.key,
    required super.isEditable,
    required BuildContext context,
    required this.taskId,
  }) : super(
          hintText: AppLocalizations.of(context)!.description,
          descriptionProvider: taskStreamProvider(taskId)
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
    required super.enabled,
    required this.taskId,
  }) : super(
          assigneesProvider: usersInTaskStreamProvider(taskId)
              .select((users) => users.value ?? []),
          projectIdProvider: taskStreamProvider(taskId)
              .select((task) => task.value?.parentProjectId),
          updateAssignees: (ref, assignees) => ref
              .read(taskAssignmentsServiceProvider)
              .updateAssignees(taskId: taskId, assignees: assignees ?? []),
        );
}
