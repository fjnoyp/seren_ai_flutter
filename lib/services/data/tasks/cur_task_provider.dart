import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_user_assignments_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_user_assignments_model.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final curTaskProvider =
    NotifierProvider<CurTaskNotifier, JoinedTaskModel>(CurTaskNotifier.new);

class CurTaskNotifier extends Notifier<JoinedTaskModel> {
  @override
  JoinedTaskModel build() {
    return JoinedTaskModel.empty();
  }

  void setNewTask(JoinedTaskModel joinedTask) {
    state = joinedTask;
  }

  void setToNewTask(UserModel authorUser) {
    state = JoinedTaskModel.empty().copyWith(authorUser: authorUser, task: TaskModel.defaultTask().copyWith(authorUserId: authorUser.id));
  }

  bool isValidTask() {
    return state.task.name.isNotEmpty && state.task.parentProjectId.isNotEmpty;
  }

  void updateAssignees(List<UserModel> assignees) {
    state = state.copyWith(
      assignees: assignees,
    );
  }

  void updateTask(TaskModel task) {
    state = state.copyWith(task: task);
  }

  // We must showDatePicker and update in same method 
  // As the original ref is invalidated after showDatePicker returns 
  Future<void> pickAndUpdateDueDate(BuildContext context) async {

    final DateTime now = DateTime.now();
    final DateTime initialDate = state.task.dueDate?.toLocal() ?? now;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
          final TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(initialDate),
          );

          if (pickedTime != null) {
            final DateTime pickedDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            ).toUtc();

            updateDueDate(pickedDateTime);
      }
    }
  }

  void updateTaskName(String name) {
    state = state.copyWith(task: state.task.copyWith(name: name));
  }

  void updateDueDate(DateTime? dueDate) {
    state = state.copyWith(task: state.task.copyWith(dueDate: dueDate));
  }

  void updateParentProject(ProjectModel? project) {
    state = state.copyWith(task: state.task.copyWith(parentProjectId: project?.id), project: project);
  }

  void updateTeam(TeamModel? team) {
    state = state.copyWith(task: state.task.copyWith(parentTeamId: team?.id), team: team);
  }

  void updateAllFields(JoinedTaskModel joinedTask) {
    state = joinedTask;
  }
}

// Providers for individual fields

final curTaskAssigneesProvider = Provider<List<UserModel>>((ref) {
  return ref.watch(curTaskProvider.select((state) => 
    state.assignees));
});

final curTaskProjectProvider = Provider<ProjectModel?>((ref) {
  return ref.watch(curTaskProvider.select((state) => state.project));
});

final curTaskTeamProvider = Provider<TeamModel?>((ref) {
  return ref.watch(curTaskProvider.select((state) => state.team));
});

final curTaskProjectIdProvider = Provider<String?>((ref) {
  return ref.watch(curTaskProvider.select((state) => state.task.parentProjectId));
});

final curTaskDueDateProvider = Provider<DateTime?>((ref) {
  return ref.watch(curTaskProvider.select((state) => state.task.dueDate));
});
