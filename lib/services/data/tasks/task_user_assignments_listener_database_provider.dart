import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_user_assignments.dart';
import 'package:seren_ai_flutter/services/data/common/base_watch_cur_auth_user_notifier.dart';
import 'package:seren_ai_flutter/services/data/common/base_listener_database_notifier.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final taskUserAssignmentsListenerDatabaseProvider = StateNotifierProvider<TaskUserAssignmentsListNotifier, List<TaskUserAssignments>?>((ref) {

  return TaskUserAssignmentsListNotifier(ref);
});

class TaskUserAssignmentsListNotifier extends BaseWatchCurAuthUserNotifier<TaskUserAssignments> {
  TaskUserAssignmentsListNotifier(super.ref)
      : super(
          createWatchingNotifier: (UserModel curUserModel) {
            return BaseListenerDatabaseNotifier<TaskUserAssignments>(
              tableName: 'task_user_assignments',
              eqFilters: [
                {'key': 'user_id', 'value': curUserModel.id},
              ],
              fromJson: (json) => TaskUserAssignments.fromJson(json),
            );
          },
        );
}
