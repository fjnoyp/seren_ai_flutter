import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart';
import 'package:seren_ai_flutter/services/data/db_setup/powersync_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final testTasksProvider = NotifierProvider<TasksNotifier, List<UserModel>>(
  () {
    return TasksNotifier(); 
});

class TasksNotifier extends Notifier<List<UserModel>> {

  // We initialize the list of todos to an empty list
  @override
  List<UserModel> build() {
    _listen();

    return [];
  }

  void _listen(){
    final db = ref.read(powerSyncProvider);
    final results = db.watch('SELECT * FROM users ORDER BY id');

    final test = results.map((results) {
      return results.map((row) {
        return UserModel.fromJson(row);
      }).toList();
    }); 

    test.listen((value) {
      state = value;
    });
  }

}

class TestSQLPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(testTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Test SQL Page'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(tasks[index].id),
            subtitle: Text(tasks[index].email ?? 'No description'),
          );
        },
      ),
    );
  }
}
