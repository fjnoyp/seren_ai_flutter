import 'package:seren_ai_flutter/services/data/common/widgets/form/base_assignees_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_text_block_edit_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_due_date_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_priority_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_project_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_status_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_task_name_field.dart';
import 'package:seren_ai_flutter/services/data/projects/cur_user_viewable_projects_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/ui_state/cur_task_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/ui_state/cur_task_states.dart';

class TaskProjectSelectionField extends BaseProjectSelectionField {
  TaskProjectSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          projectProvider: curTaskProjectProvider,
          selectableProjectsProvider: curUserViewableProjectsListenerProvider,
          updateProject: (ref, project) =>
              ref.read(curTaskProvider.notifier).updateParentProject(project),
        );
}

class TaskStatusSelectionField extends BaseStatusSelectionField {
  TaskStatusSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          statusProvider: curTaskProvider.select((state) => switch (state) {
                LoadedCurTaskState() => state.task.task.status,
                _ => null,
              }),
          updateStatus: (ref, status) =>
              ref.read(curTaskProvider.notifier).updateStatus(status),
        );
}

class TaskPrioritySelectionField extends BasePrioritySelectionField {
  TaskPrioritySelectionField({
    super.key,
    required super.enabled,
  }) : super(
          priorityProvider: curTaskProvider.select((state) => switch (state) {
                LoadedCurTaskState() => state.task.task.priority,
                _ => null,
              }),
          updatePriority: (ref, priority) =>
              ref.read(curTaskProvider.notifier).updatePriority(priority),
        );
}

class TaskNameField extends BaseNameField {
  TaskNameField({
    super.key,
    required super.enabled,
  }) : super(
          nameProvider: curTaskProvider.select((state) => switch (state) {
                LoadedCurTaskState() => state.task.task.name,
                _ => '',
              }),
          updateName: (ref, name) =>
              ref.read(curTaskProvider.notifier).updateTaskName(name),
        );
}

class TaskDueDateSelectionField extends BaseDueDateSelectionField {
  TaskDueDateSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          dueDateProvider: curTaskProvider.select((state) => switch (state) {
                LoadedCurTaskState() => state.task.task.dueDate,
                _ => null,
              }),
          updateDueDate: (ref, pickedDateTime) =>
              ref.read(curTaskProvider.notifier).updateDueDate(pickedDateTime),
        );
}

class TaskDescriptionSelectionField extends BaseTextBlockEditSelectionField {
  TaskDescriptionSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          descriptionProvider:
              curTaskProvider.select((state) => switch (state) {
                    LoadedCurTaskState() => state.task.task.description,
                    _ => null,
                  }),
          updateDescription: (ref, description) =>
              ref.read(curTaskProvider.notifier).updateDescription(description),
        );
}

class TaskAssigneesSelectionField extends BaseAssigneesSelectionField {
  TaskAssigneesSelectionField({
    super.key,
    required super.enabled,
  }) : super(
            assigneesProvider: curTaskAssigneesProvider,
            projectProvider: curTaskProjectProvider,
            updateAssignees: (ref, assignees) =>
                ref.read(curTaskProvider.notifier).updateAssignees(assignees));
}
