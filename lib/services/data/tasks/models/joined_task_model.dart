import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_comments_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

class JoinedTaskModel {
  final TaskModel task;
  final UserModel? authorUser;
  final ProjectModel? project;
  final List<UserModel> assignees;
  final List<TaskCommentsModel> comments;

  JoinedTaskModel(
      {required this.task,
      required this.authorUser,
      required this.project,
      required this.assignees,
      required this.comments});

  static JoinedTaskModel empty() {
    return JoinedTaskModel(
      task: TaskModel.defaultTask(),
      authorUser: null,
      project: null,
      assignees: [],
      comments: [],
    );
  }

  JoinedTaskModel copyWith({
    TaskModel? task,
    UserModel? authorUser,
    ProjectModel? project,
    List<UserModel>? assignees,
    List<TaskCommentsModel>? comments,
  }) {
    return JoinedTaskModel(
      task: task ?? this.task,
      authorUser: authorUser ?? this.authorUser,
      project: project ?? this.project,
      assignees: assignees ?? this.assignees,
      comments: comments ?? this.comments,
    );
  }

  /*
  static Future<JoinedTaskModel> fromTaskModel(WidgetRef ref, TaskModel taskModel) async {

    final authorId = taskModel.authorUserId;
    final authorUser = await ref.read(usersReadProvider).getItem(id: authorId);

    final projectId = taskModel.parentProjectId;
    final project = await ref.read(projectsReadProvider).getItem(id: projectId);

    // TODO p5: fetch assignees and comments as well 

    return JoinedTaskModel(task: taskModel, authorUser: authorUser, project: project, team: team);
  }
  */
}
