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
    return JoinedTaskModel(
      task: TaskModel.defaultTask(),
      authorUser: null,
      project: null,
      team: null,
      assignees: [],
      comments: [],
    );
  }

  void setNewTask(JoinedTaskModel joinedTask) {
    state = joinedTask;
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

  Future<void> pickAndUpdateDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: state.task.dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      updateDueDate(picked);
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
