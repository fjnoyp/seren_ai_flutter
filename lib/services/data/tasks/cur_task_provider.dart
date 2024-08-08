import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final curTaskProvider =
    NotifierProvider<CurTaskNotifier, CurTaskState>(CurTaskNotifier.new);

class CurTaskState {
  final TaskModel task;
  final UserModel? authorUser;
  final ProjectModel? parentProject;
  final TeamModel? team;
  final Set<UserModel>? assignees;

  CurTaskState({
    required this.task,
    required this.authorUser,
    required this.parentProject,
    required this.team,
    required this.assignees,
  });

  CurTaskState copyWith({
    TaskModel? task,
    UserModel? authorUser,
    ProjectModel? parentProject,
    TeamModel? team,
    Set<UserModel>? assignees,
  }) {
    return CurTaskState(
      task: task ?? this.task,
      authorUser: authorUser ?? this.authorUser,
      parentProject: parentProject ?? this.parentProject,
      team: team ?? this.team,
      assignees: assignees ?? this.assignees,
    );
  }
}

class CurTaskNotifier extends Notifier<CurTaskState> {
  @override
  CurTaskState build() {
    return CurTaskState(
      task: TaskModel.defaultTask(),
      authorUser: null,
      parentProject: null,
      team: null,
      assignees: null,
    );
  }

  bool isValidTask() {
    return state.task.name.isNotEmpty && state.task.parentProjectId.isNotEmpty;
  }

  void updateAssignees(Set<UserModel>? assignees) {
    state = state.copyWith(assignees: assignees);
  }

  void updateTask(TaskModel task) {
    state = state.copyWith(task: task);
  }

// Hack to prevent "Cannot use "ref" after the widget was disposed" when showing date picker and accessing ref.read to update dueDate
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

  void updateDueDate(DateTime? dueDate) {
    state = state.copyWith(task: state.task.copyWith(dueDate: dueDate));
  }

  void updateParentProject(ProjectModel? project) {
    state = state.copyWith(parentProject: project);
  }

  void updateTeam(TeamModel? team) {
    state = state.copyWith(team: team);
  }
}

// Providers for individual fields

final curTaskAssigneesProvider = Provider<Set<UserModel>?>((ref) {
  return ref.watch(curTaskProvider.select((state) => state.assignees));
});

final curTaskProjectProvider = Provider<ProjectModel?>((ref) {
  return ref.watch(curTaskProvider.select((state) => state.parentProject));
});

final curTaskTeamProvider = Provider<TeamModel?>((ref) {
  return ref.watch(curTaskProvider.select((state) => state.team));
});

final curTaskProjectIdProvider = Provider<String?>((ref) {
  return ref
      .watch(curTaskProvider.select((state) => state.task.parentProjectId));
});

final curTaskDueDateProvider = Provider<DateTime?>((ref) {
  return ref.watch(curTaskProvider.select((state) => state.task.dueDate));
});

/*
final taskNameProvider = Provider<String>((ref) {
  return ref.watch(currentTaskNotifierProvider.select((state) => state.name));
});

final taskDescriptionProvider = Provider<String?>((ref) {
  return ref.watch(currentTaskNotifierProvider.select((state) => state.description));
});

final taskStatusEnumProvider = Provider<StatusEnum?>((ref) {
  return ref.watch(currentTaskNotifierProvider.select((state) => state.statusEnum));
});
*/

// Add similar providers for other fields...
