import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_comments_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_reminder_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

class JoinedTaskModel {
  final TaskModel task;
  final UserModel? authorUser;
  final ProjectModel? project;
  final List<UserModel> assignees;
  final List<TaskCommentsModel> comments;
  final TaskReminderModel? reminder;

  JoinedTaskModel({
    required this.task,
    required this.authorUser,
    required this.project,
    required this.assignees,
    required this.comments,
    required this.reminder,
  });

  static JoinedTaskModel empty() {
    return JoinedTaskModel(
      task: TaskModel.defaultTask(),
      authorUser: null,
      project: null,
      assignees: [],
      comments: [],
      reminder: null,
    );
  }

  JoinedTaskModel copyWith({
    TaskModel? task,
    UserModel? authorUser,
    ProjectModel? project,
    List<UserModel>? assignees,
    List<TaskCommentsModel>? comments,
    TaskReminderModel? reminder,
    bool removeReminder = false,
  }) {
    return JoinedTaskModel(
      task: task ?? this.task,
      authorUser: authorUser ?? this.authorUser,
      project: project ?? this.project,
      assignees: assignees ?? this.assignees,
      comments: comments ?? this.comments,
      reminder: removeReminder ? null : reminder ?? this.reminder,
    );
  }

  factory JoinedTaskModel.fromJson(Map<String, dynamic> json) {
    final task = TaskModel.fromJson(json['task']);
    final authorUser = json['author_user'] != null
        ? UserModel.fromJson(json['author_user'])
        : null;
    final project =
        json['project'] != null ? ProjectModel.fromJson(json['project']) : null;
    final assignees = <UserModel>[
      ...json['assignees']
          .where((e) => e != null)
          .map((e) => UserModel.fromJson(e))
    ];
    final comments = <TaskCommentsModel>[
      ...json['comments']
          .where((e) => e != null)
          .map((e) => TaskCommentsModel.fromJson(e))
    ];
    final reminder = json['reminder'] != null
        ? TaskReminderModel.fromJson(json['reminder'])
        : null;

    return JoinedTaskModel(
      task: task,
      authorUser: authorUser,
      project: project,
      assignees: assignees,
      comments: comments,
      reminder: reminder,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task': task.toJson(),
      'author_user': authorUser?.toJson(),
      'project': project?.toJson(),
      'assignees': assignees.map((e) => e.toJson()).toList(),
      'comments': comments.map((e) => e.toJson()).toList(),
      'reminder': reminder?.toJson(),
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
      'reminder': reminder?.toJson(),
    };
  }
}
