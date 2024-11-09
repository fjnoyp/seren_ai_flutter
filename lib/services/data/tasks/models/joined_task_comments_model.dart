import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_comments_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';

class JoinedTaskCommentsModel {
  final TaskCommentsModel comment;
  final UserModel? authorUser;
  final TaskModel? parentTask;

  JoinedTaskCommentsModel({
    required this.comment,
    this.authorUser,
    this.parentTask,
  });

  factory JoinedTaskCommentsModel.empty() {
    return JoinedTaskCommentsModel(
      comment: TaskCommentsModel(authorUserId: '', parentTaskId: ''),
      authorUser: null,
      parentTask: null,
    );
  }

  Future<JoinedTaskCommentsModel> setUser(Ref ref) async {
    final user = await ref
        .read(usersRepositoryProvider)
        .getUser(userId: comment.authorUserId);

    return copyWith(authorUser: user);
  }

  JoinedTaskCommentsModel copyWith({
    TaskCommentsModel? comment,
    UserModel? authorUser,
    TaskModel? parentTask,
  }) {
    return JoinedTaskCommentsModel(
      comment: comment ?? this.comment,
      authorUser: authorUser ?? this.authorUser,
      parentTask: parentTask ?? this.parentTask,
    );
  }

  factory JoinedTaskCommentsModel.fromJson(Map<String, dynamic> json) {
    final commentJson = jsonDecode(json['comment']);
    final authorUserJson = jsonDecode(json['author_user']);
    final parentTaskJson = jsonDecode(json['parent_task']);

    final comment = TaskCommentsModel.fromJson(commentJson);
    final authorUser =
        authorUserJson != null ? UserModel.fromJson(authorUserJson) : null;
    final parentTask =
        parentTaskJson != null ? TaskModel.fromJson(parentTaskJson) : null;

    return JoinedTaskCommentsModel(
      comment: comment,
      authorUser: authorUser,
      parentTask: parentTask,
    );
  }
}
