import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:powersync/powersync.dart' hide Column;
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final testTasksProvider = NotifierProvider<TasksNotifier, List<UserModel>>(
  () {
    return TasksNotifier(); 
});

class TasksNotifier extends Notifier<List<UserModel>> {

  // We initialize the list of todos to an empty list
  @override
  List<UserModel> build() {
    final user = ref.watch(curAuthUserProvider); 
    if(user == null) {
      return [];
    }

    _listen();

    return [];
  }

  void _listen(){
    final db = ref.read(dbProvider);

    db.watch('SELECT * FROM users ORDER BY id').listen((results) {
      final items = results.map((row) => UserModel.fromJson(row)).toList();
      state = items;
    });
  }

}

class TestSQLPage extends HookConsumerWidget {
  final TextEditingController _sqlController = TextEditingController();

  

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final sqlResult = useState<String>(''); 

    return Scaffold(
      appBar: AppBar(
        title: Text('Test SQL Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _sqlController,
              decoration: InputDecoration(
                labelText: 'Enter SQL query',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              minLines: 1,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final db = ref.read(dbProvider);
                final results = await db.execute(_sqlController.text);
                final items = results.map((row) => row.values).toList();                
                sqlResult.value = items.toString();
              },
              child: Text('Execute SQL'),
            ),
            Text(sqlResult.value),
          ],
        ),
      ),
    );
  }
}
