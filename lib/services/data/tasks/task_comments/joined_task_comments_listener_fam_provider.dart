import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_comments_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_comments/task_comments_listener_fam_provider.dart';
import 'package:seren_ai_flutter/services/data/users/users_read_provider.dart';
import 'package:collection/collection.dart';

final joinedTaskCommentsListenerFamProvider = NotifierProvider.family<
    JoinedTaskCommentsListenerFamNotifier,
    List<JoinedTaskCommentsModel>?,
    String>(JoinedTaskCommentsListenerFamNotifier.new);

class JoinedTaskCommentsListenerFamNotifier
    extends FamilyNotifier<List<JoinedTaskCommentsModel>?, String> {
  @override
  List<JoinedTaskCommentsModel>? build(String arg) {
    _listen();
    return null;
  }

  Future<void> _listen() async {
    final taskId = arg;

    final taskComments = ref.watch(taskCommentsListenerFamProvider(taskId));

    if (taskComments == null) {
      return;
    }

    final userIds =
        taskComments.map((comment) => comment.authorUserId).toList();
    final authorUsers =
        await ref.read(usersReadProvider).getItems(ids: userIds);

    final joinedComments = taskComments.map((comment) {
      final authorUser = authorUsers
          .firstWhereOrNull((user) => user.id == comment.authorUserId);
      return JoinedTaskCommentsModel(
        comment: comment,
        authorUser: authorUser,
      );
    }).toList();

    state = joinedComments;
  }
}
