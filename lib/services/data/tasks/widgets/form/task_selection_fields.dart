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
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_task_service_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_task_state_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TaskProjectSelectionField extends BaseProjectSelectionField {
  TaskProjectSelectionField({
    super.key,
    required super.isEditable,
  }) : super(
          projectProvider:
              curTaskStateProvider.select((state) => state.value?.project),
          selectableProjectsProvider: curUserViewableProjectsProvider,
          updateProject: (ref, project) =>
              ref.read(curTaskServiceProvider).updateParentProject(project),
        );
}

class TaskStatusSelectionField extends BaseStatusSelectionField {
  TaskStatusSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          statusProvider:
              curTaskStateProvider.select((state) => state.value?.task.status),
          updateStatus: (ref, status) =>
              ref.read(curTaskServiceProvider).updateStatus(status),
        );
}

class TaskPrioritySelectionField extends BasePrioritySelectionField {
  TaskPrioritySelectionField({
    super.key,
    required super.enabled,
  }) : super(
          priorityProvider: curTaskStateProvider
              .select((state) => state.value?.task.priority),
          updatePriority: (ref, priority) =>
              ref.read(curTaskServiceProvider).updatePriority(priority),
        );
}

class TaskNameField extends BaseNameField {
  TaskNameField({
    super.key,
    required super.isEditable,
  }) : super(
          nameProvider: curTaskStateProvider
              .select((state) => state.value?.task.name ?? ''),
          updateName: (ref, name) =>
              ref.read(curTaskServiceProvider).updateTaskName(name),
        );
}

class TaskDueDateSelectionField extends BaseDueDateSelectionField {
  TaskDueDateSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          dueDateProvider:
              curTaskStateProvider.select((state) => state.value?.task.dueDate),
          updateDueDate: (ref, pickedDateTime) =>
              ref.read(curTaskServiceProvider).updateDueDate(pickedDateTime),
        );
}

class ReminderMinuteOffsetFromDueDateSelectionField
    extends BaseMinuteSelectionField {
  ReminderMinuteOffsetFromDueDateSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          reminderProvider: curTaskStateProvider
              .select((state) => state.value?.task.reminderOffsetMinutes),
          updateReminder: (ref, reminder) =>
              ref.read(curTaskServiceProvider).setReminder(reminder),
          labelWidgetBuilder: (ref) => ref
                      .watch(curTaskStateProvider)
                      .value
                      ?.task
                      .reminderOffsetMinutes ==
                  null
              ? const Icon(Icons.notifications_off)
              : const Icon(Icons.notifications),
        );
}

class TaskDescriptionSelectionField extends BaseTextBlockEditSelectionField {
  TaskDescriptionSelectionField({
    super.key,
    required super.isEditable,
    required BuildContext context,
  }) : super(
          hintText: AppLocalizations.of(context)!.description,
          descriptionProvider: curTaskStateProvider
              .select((state) => state.value?.task.description ?? ''),
          updateDescription: (ref, description) =>
              ref.read(curTaskServiceProvider).updateDescription(description),
        );
}

class TaskAssigneesSelectionField extends BaseAssigneesSelectionField {
  TaskAssigneesSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          assigneesProvider: curTaskStateProvider
              .select((state) => state.value?.assignees ?? []),
          projectProvider:
              curTaskStateProvider.select((state) => state.value?.project),
          updateAssignees: (ref, assignees) =>
              ref.read(curTaskServiceProvider).updateAssignees(assignees),
        );
}
