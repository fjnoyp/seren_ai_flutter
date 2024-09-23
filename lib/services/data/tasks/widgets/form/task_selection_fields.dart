import 'package:seren_ai_flutter/services/data/common/widgets/form/base_assignees_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_text_block_edit_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_due_date_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_priority_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_project_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_status_selection_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_task_name_field.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_team_selection_field.dart';
import 'package:seren_ai_flutter/services/data/projects/cur_user_viewable_projects_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/ui_state/cur_task_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/cur_team/cur_user_viewable_teams_listener_provider.dart';

class TaskTeamSelectionField extends BaseTeamSelectionField {
  TaskTeamSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          teamProvider: curTaskTeamProvider,
          selectableTeamsProvider: curUserViewableTeamsListenerProvider,
          updateTeam: (ref, team) =>
              ref.read(curTaskProvider.notifier).updateTeam(team),
        );
}

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
          statusProvider: curTaskProvider.select((state) => state.task.status),
          updateStatus: (ref, status) => ref
              .read(curTaskProvider.notifier)
              .updateTask(
                  ref.read(curTaskProvider).task.copyWith(status: status)),
        );
}

class TaskPrioritySelectionField extends BasePrioritySelectionField {
  TaskPrioritySelectionField({
    super.key,
    required super.enabled,
  }) : super(
          priorityProvider:
              curTaskProvider.select((state) => state.task.priority),
          updatePriority: (ref, priority) => ref
              .read(curTaskProvider.notifier)
              .updateTask(
                  ref.read(curTaskProvider).task.copyWith(priority: priority)),
        );
}

class TaskNameField extends BaseNameField {
  TaskNameField({
    super.key,
    required super.enabled,
  }) : super(
          nameProvider: curTaskProvider.select((state) => state.task.name),
          updateName: (ref, name) => 
              ref.read(curTaskProvider.notifier).updateTaskName(name),
        );
}

class TaskDueDateSelectionField extends BaseDueDateSelectionField {
  TaskDueDateSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          dueDateProvider: curTaskDueDateProvider,
          pickAndUpdateDueDate: (ref, context) => 
              ref.read(curTaskProvider.notifier).pickAndUpdateDueDate(context),
        );
}

class TaskDescriptionSelectionField extends BaseTextBlockEditSelectionField {
 TaskDescriptionSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          descriptionProvider: curTaskProvider.select((state) => state.task.description),
          updateDescription: (ref, description) => 
              ref.read(curTaskProvider.notifier).updateTask(
                ref.read(curTaskProvider).task.copyWith(description: description)
              ),
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
              ref.read(curTaskProvider.notifier).updateAssignees(assignees)
        );
}