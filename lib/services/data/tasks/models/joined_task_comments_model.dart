import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_comments_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/users/users_read_provider.dart';

class JoinedTaskCommentsModel {
  final TaskCommentsModel comment;
  final UserModel? authorUser;
  final TaskModel? parentTask;

  JoinedTaskCommentsModel({
    required this.comment,
    this.authorUser,
    this.parentTask,
  });

  // obs.: I think it's a better idea to use a factory constructor instead of a static method
  factory JoinedTaskCommentsModel.empty() {
    return JoinedTaskCommentsModel(
      comment: TaskCommentsModel(authorUserId: '', parentTaskId: ''),
      authorUser: null,
      parentTask: null,
    );
  }

  // obs.:
  Future<JoinedTaskCommentsModel> setUser(NotifierProviderRef ref) async {
    return copyWith(
      authorUser:
          await ref.read(usersReadProvider).getItem(id: comment.authorUserId),
    );
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
}
