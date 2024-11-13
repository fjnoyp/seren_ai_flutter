import 'dart:convert';

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

  factory JoinedTaskModel.fromJson(Map<String, dynamic> json) {
    final task = TaskModel.fromJson(json['task']);
    final authorUser = UserModel.fromJson(json['author_user']);
    final project = ProjectModel.fromJson(json['project']);
    final decodedAssignees = json['assignees'] as List<dynamic>;
    final assigneesJson = decodedAssignees.first == null
        ? []
        : decodedAssignees;
    final decodedComments = json['comments'] as List<dynamic>;
    final commentsJson = decodedComments.first == null
        ? []
        : decodedComments;

    final assignees = <UserModel>[
      ...assigneesJson.map((e) => UserModel.fromJson(e))
    ];
    final comments = <TaskCommentsModel>[
      ...commentsJson.map((e) => TaskCommentsModel.fromJson(e))
    ];

    return JoinedTaskModel(
      task: task,
      authorUser: authorUser,
      project: project,
      assignees: assignees,
      comments: comments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task': task.toJson(),
      'author_user': authorUser?.toJson(),
      'project': project?.toJson(),
      'assignees': assignees.map((e) => e.toJson()).toList(),
      'comments': comments.map((e) => e.toJson()).toList(),
    };
  }

  bool get isValidTask =>
      task.name.isNotEmpty && task.parentProjectId.isNotEmpty;

  Map<String, dynamic> toReadableMap() {
    return {
      'task': {
        'name': task.name,
        'description': task.description,
        'status': task.status,
        'priority': task.priority,
        'due_date': task.dueDate?.toIso8601String(),
      },
      'author': authorUser?.email ?? 'Unknown',
      'project': project?.name ?? 'No Project',
      'assignees': assignees.map((user) => user.email).toList(),
    };
  }
}
