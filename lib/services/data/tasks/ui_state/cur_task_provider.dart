import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/projects_read_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_comments_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_comments/task_comments_listener_fam_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_comments_db_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';
import 'package:seren_ai_flutter/services/data/teams/teams_read_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/ui_state/cur_task_states.dart';

final curTaskProvider =
    NotifierProvider<CurTaskNotifier, CurTaskState>(CurTaskNotifier.new);

class CurTaskNotifier extends Notifier<CurTaskState> {
  @override
  CurTaskState build() {
    return InitialCurTaskState();
  }

  void setNewTask(JoinedTaskModel joinedTask) {
    state = LoadedCurTaskState(joinedTask);
  }

  Future<void> setToNewTask() async {
    state = LoadingCurTaskState();
    try {
      final curAuthUserState = ref.read(curAuthStateProvider);
      if (switch (curAuthUserState) {
        LoggedInAuthState() => curAuthUserState.user,
        _ => null,
      }
          case final curUser?) {
        final defaultTeam =
            await ref.read(teamsReadProvider).getItem(eqFilters: [
          {'key': 'id', 'value': curUser.defaultTeamId}
        ]);
        final defaultProject =
            await ref.read(projectsReadProvider).getItem(eqFilters: [
          {'key': 'id', 'value': curUser.defaultProjectId}
        ]);
        final newTask = JoinedTaskModel.empty().copyWith(
          authorUser: curUser,
          task: TaskModel.defaultTask().copyWith(
            authorUserId: curUser.id,
            parentTeamId: defaultTeam?.id,
            parentProjectId: defaultProject?.id,
          ),
          team: defaultTeam,
          project: defaultProject,
        );
        state = LoadedCurTaskState(newTask);
      } else {
        throw Exception('Error: Current user is not authenticated.');
      }
    } catch (error) {
      state = ErrorCurTaskState(error: error.toString());
    }
  }

  bool isValidTask() {
    if (state is LoadedCurTaskState) {
      final loadedState = state as LoadedCurTaskState;
      return loadedState.task.task.name.isNotEmpty &&
          loadedState.task.task.parentProjectId.isNotEmpty;
    }
    return false;
  }

  void updateAssignees(List<UserModel> assignees) {
    if (state is LoadedCurTaskState) {
      final loadedState = state as LoadedCurTaskState;
      state =
          LoadedCurTaskState(loadedState.task.copyWith(assignees: assignees));
    }
  }

  void updateTask(TaskModel task) {
    if (state is LoadedCurTaskState) {
      final loadedState = state as LoadedCurTaskState;
      state = LoadedCurTaskState(loadedState.task.copyWith(task: task));
    }
  }

  void updateStatus(StatusEnum? status) {
    if (state is LoadedCurTaskState) {
      final loadedState = state as LoadedCurTaskState;
      state = LoadedCurTaskState(loadedState.task
          .copyWith(task: loadedState.task.task.copyWith(status: status)));
    }
  }

  void updatePriority(PriorityEnum? priority) {
    if (state is LoadedCurTaskState) {
      final loadedState = state as LoadedCurTaskState;
      state = LoadedCurTaskState(loadedState.task
          .copyWith(task: loadedState.task.task.copyWith(priority: priority)));
    }
  }

  void updateDescription(String? description) {
    if (state is LoadedCurTaskState) {
      final loadedState = state as LoadedCurTaskState;
      state = LoadedCurTaskState(loadedState.task.copyWith(
          task: loadedState.task.task.copyWith(description: description)));
    }
  }

  // We must showDatePicker and update in same method
  // As the original ref is invalidated after showDatePicker returns

  Future<void> pickAndUpdateDueDate(BuildContext context) async {
    if (state is LoadedCurTaskState) {
      final loadedState = state as LoadedCurTaskState;
      final DateTime now = DateTime.now();
      final DateTime initialDate =
          loadedState.task.task.dueDate?.toLocal() ?? now;

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
  }

  void updateTaskName(String name) {
    if (state is LoadedCurTaskState) {
      final loadedState = state as LoadedCurTaskState;
      state = LoadedCurTaskState(loadedState.task
          .copyWith(task: loadedState.task.task.copyWith(name: name)));
    }
  }

  void updateDueDate(DateTime? dueDate) {
    if (state is LoadedCurTaskState) {
      final loadedState = state as LoadedCurTaskState;
      state = LoadedCurTaskState(loadedState.task
          .copyWith(task: loadedState.task.task.copyWith(dueDate: dueDate)));
    }
  }

  void updateParentProject(ProjectModel? project) {
    if (state is LoadedCurTaskState) {
      final loadedState = state as LoadedCurTaskState;
      state = LoadedCurTaskState(loadedState.task.copyWith(
          task: loadedState.task.task.copyWith(parentProjectId: project?.id),
          project: project));
    }
  }

  void updateTeam(TeamModel? team) {
    if (state is LoadedCurTaskState) {
      final loadedState = state as LoadedCurTaskState;
      state = LoadedCurTaskState(loadedState.task.copyWith(
          task: loadedState.task.task.copyWith(parentTeamId: team?.id),
          team: team));
    }
  }

  void updateAllFields(JoinedTaskModel joinedTask) {
    state = LoadedCurTaskState(joinedTask);
  }

  void addComment(String text) {
    if (state is LoadedCurTaskState) {
      final loadedState = state as LoadedCurTaskState;
      final curAuthUserState = ref.read(curAuthStateProvider);
      final curUser = switch (curAuthUserState) {
        LoggedInAuthState() => curAuthUserState.user,
        _ => null,
      };
      final comment = TaskCommentsModel(
        authorUserId: curUser!.id,
        parentTaskId: loadedState.task.task.id,
        content: text,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );
      ref.read(taskCommentsDbProvider).upsertItem(comment);
      state = LoadedCurTaskState(loadedState.task
          .copyWith(comments: [...loadedState.task.comments, comment]));
    }
  }

  Future<void> updateComments() async {
    if (state is LoadedCurTaskState) {
      final loadedState = state as LoadedCurTaskState;
      final comments =
          ref.read(taskCommentsListenerFamProvider(loadedState.task.task.id)) ??
              [];

      state = LoadedCurTaskState(loadedState.task.copyWith(comments: comments));
    }
  }
}

// Providers for individual fields

final curTaskAssigneesProvider = Provider<List<UserModel>>((ref) {
  final curTaskState = ref.watch(curTaskProvider);
  return switch (curTaskState) {
    LoadedCurTaskState() => curTaskState.task.assignees,
    _ => [],
  };
});

final curTaskProjectProvider = Provider<ProjectModel?>((ref) {
  final curTaskState = ref.watch(curTaskProvider);
  return switch (curTaskState) {
    LoadedCurTaskState() => curTaskState.task.project,
    _ => null,
  };
});

final curTaskTeamProvider = Provider<TeamModel?>((ref) {
  final curTaskState = ref.watch(curTaskProvider);
  return switch (curTaskState) {
    LoadedCurTaskState() => curTaskState.task.team,
    _ => null,
  };
});

final curTaskProjectIdProvider = Provider<String?>((ref) {
  final curTaskState = ref.watch(curTaskProvider);
  return switch (curTaskState) {
    LoadedCurTaskState() => curTaskState.task.task.parentProjectId,
    _ => null,
  };
});

final curTaskDueDateProvider = Provider<DateTime?>((ref) {
  final curTaskState = ref.watch(curTaskProvider);
  return switch (curTaskState) {
    LoadedCurTaskState() => curTaskState.task.task.dueDate,
    _ => null,
  };
});
