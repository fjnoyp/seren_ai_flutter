import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_watch_cur_auth_user_notifier.dart';
import 'package:seren_ai_flutter/services/data/common/base_listener_database_notifier.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final curUserTasksListListenerDatabaseProvider = StateNotifierProvider<CurUserTasksListNotifier, List<TaskModel>?>((ref) {
  return CurUserTasksListNotifier(ref);
});

/// Get the current team's tasks
class CurUserTasksListNotifier extends BaseWatchCurAuthUserNotifier<TaskModel> {
  CurUserTasksListNotifier(super.ref)
      : super(
          createWatchingNotifier: (UserModel curUserModel) {
            return BaseListenerDatabaseNotifier<TaskModel>(
              tableName: 'tasks',
              eqFilters: [
                {'key': 'assigned_user_id', 'value': curUserModel.id},
              ],
              fromJson: (json) => TaskModel.fromJson(json),
            );
          },
        );
}
