import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

/// Provide all tasks assigned to current user 
final curUserViewableTasksListenerProvider =
    NotifierProvider<CurUserAssignedTaskListenerNotifier, List<TaskModel>?>(
        CurUserAssignedTaskListenerNotifier.new);

class CurUserAssignedTaskListenerNotifier extends Notifier<List<TaskModel>?> {
  @override
  List<TaskModel>? build() {
    

    final watchedCurAuthUser = ref.watch(curAuthUserProvider);

    if(watchedCurAuthUser == null) {
      return null;
    }

    final db = ref.read(dbProvider);  
  
    final query = '''
    SELECT DISTINCT t.*
    FROM tasks t
    LEFT JOIN task_user_assignments tua ON t.id = tua.task_id
    WHERE tua.user_id = '${watchedCurAuthUser.id}'
    OR t.author_user_id = '${watchedCurAuthUser.id}';
    ''';

    //final query = 'SELECT * FROM tasks';

    final subscription = db.watch(query).listen((results) {
      List<TaskModel> items = results.map((e) => TaskModel.fromJson(e)).toList();
      state = items;      
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return null;
  }
}
