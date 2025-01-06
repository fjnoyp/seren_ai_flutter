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
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_editing_task_state_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TaskProjectSelectionField extends BaseProjectSelectionField {
  TaskProjectSelectionField({
    super.key,
    required super.isEditable,
  }) : super(
          projectIdProvider: curEditingTaskStateProvider
              .select((state) => state.value?.taskModel.parentProjectId),
          selectableProjectsProvider: curUserViewableProjectsProvider,
          updateProject: (ref, project) => ref
              .read(curEditingTaskStateProvider.notifier)
              .updateTaskFields(parentProjectId: project!.id),
        );
}

class TaskStatusSelectionField extends BaseStatusSelectionField {
  TaskStatusSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          statusProvider: curEditingTaskStateProvider
              .select((state) => state.value?.taskModel.status),
          updateStatus: (ref, status) => ref
              .read(curEditingTaskStateProvider.notifier)
              .updateTaskFields(status: status),
        );
}

class TaskPrioritySelectionField extends BasePrioritySelectionField {
  TaskPrioritySelectionField({
    super.key,
    required super.enabled,
  }) : super(
          priorityProvider: curEditingTaskStateProvider
              .select((state) => state.value?.taskModel.priority),
          updatePriority: (ref, priority) => ref
              .read(curEditingTaskStateProvider.notifier)
              .updateTaskFields(priority: priority),
        );
}

class TaskNameField extends BaseNameField {
  TaskNameField({
    super.key,
    required super.isEditable,
  }) : super(
          nameProvider: curEditingTaskStateProvider
              .select((state) => state.value?.taskModel.name ?? ''),
          updateName: (ref, name) => ref
              .read(curEditingTaskStateProvider.notifier)
              .updateTaskFields(name: name),
        );
}

class TaskDueDateSelectionField extends BaseDueDateSelectionField {
  TaskDueDateSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          dueDateProvider: curEditingTaskStateProvider
              .select((state) => state.value?.taskModel.dueDate),
          updateDueDate: (ref, pickedDateTime) => ref
              .read(curEditingTaskStateProvider.notifier)
              .updateTaskFields(dueDate: pickedDateTime),
        );
}

class ReminderMinuteOffsetFromDueDateSelectionField
    extends BaseMinuteSelectionField {
  ReminderMinuteOffsetFromDueDateSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          reminderProvider: curEditingTaskStateProvider
              .select((state) => state.value?.taskModel.reminderOffsetMinutes),
          updateReminder: (ref, reminder) => ref
              .read(curEditingTaskStateProvider.notifier)
              .updateTaskFields(reminderOffsetMinutes: reminder),
          labelWidgetBuilder: (ref) => ref
                      .watch(curEditingTaskStateProvider)
                      .value
                      ?.taskModel
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
          descriptionProvider: curEditingTaskStateProvider
              .select((state) => state.value?.taskModel.description ?? ''),
          updateDescription: (ref, description) => ref
              .read(curEditingTaskStateProvider.notifier)
              .updateTaskFields(description: description),
        );
}

class TaskAssigneesSelectionField extends BaseAssigneesSelectionField {
  TaskAssigneesSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          assigneesProvider: curEditingTaskStateProvider
              .select((state) => state.value?.assignees ?? []),
          projectIdProvider: curEditingTaskStateProvider
              .select((state) => state.value?.taskModel.parentProjectId),
          updateAssignees: (ref, assignees) => ref
              .read(curEditingTaskStateProvider.notifier)
              .updateAssignees(assignees: assignees ?? []),
        );
}
