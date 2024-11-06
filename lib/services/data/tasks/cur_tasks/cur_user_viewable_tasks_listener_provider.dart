import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

/// Provide all tasks assigned to current user
final curUserViewableTasksListenerProvider =
    NotifierProvider<CurUserViewableTasksListenerNotifier, List<TaskModel>?>(
        CurUserViewableTasksListenerNotifier.new);

class CurUserViewableTasksListenerNotifier extends Notifier<List<TaskModel>?> {
  @override
  List<TaskModel>? build() {
    final watchedCurAuthUser = ref.read(curUserProvider).value;

    if (watchedCurAuthUser == null) {
      return null;
    }

    final db = ref.read(dbProvider);

    final query = '''
    SELECT DISTINCT t.*
    FROM tasks t
    LEFT JOIN user_project_assignments pua ON t.parent_project_id = pua.project_id
    WHERE pua.user_id = '${watchedCurAuthUser.id}'
    OR t.author_user_id = '${watchedCurAuthUser.id}';
    ''';

    final subscription = db.watch(query).listen((results) {
      List<TaskModel> items =
          results.map((e) => TaskModel.fromJson(e)).toList();
      state = items;
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return null;
  }
}
