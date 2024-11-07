import 'dart:convert';

import 'package:seren_ai_flutter/services/data/tasks/models/task_user_assignments_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

class JoinedTaskUserAssignmentsModel {
  final TaskUserAssignmentsModel assignment;
  final UserModel user;
  final TaskModel? task;

  JoinedTaskUserAssignmentsModel({
    required this.assignment,
    required this.user,
    this.task,
  });
  factory JoinedTaskUserAssignmentsModel.fromJson(Map<String, dynamic> json) {
    final assignmentJson = jsonDecode(json['assignment']);
    final userJson = jsonDecode(json['user']);
    final taskJson = json['task'] != null ? jsonDecode(json['task']) : null;

    final assignment = TaskUserAssignmentsModel.fromJson(assignmentJson);
    final user = UserModel.fromJson(userJson);
    final task = taskJson != null ? TaskModel.fromJson(taskJson) : null;

    return JoinedTaskUserAssignmentsModel(
      assignment: assignment,
      user: user,
      task: task,
    );
  }
}
