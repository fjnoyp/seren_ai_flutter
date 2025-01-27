import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/users/providers/search_users_by_name_service_provider.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';

final testTasksProvider = NotifierProvider<TasksNotifier, List<UserModel>>(() {
  return TasksNotifier();
});

class TasksNotifier extends Notifier<List<UserModel>> {
  // We initialize the list of tasks to an empty list
  @override
  List<UserModel> build() {
    _listen();

    return [];
  }

  void _listen() {
    final db = ref.read(dbProvider);

    db.watch('SELECT * FROM users ORDER BY id').listen((results) {
      final items = results.map((row) => UserModel.fromJson(row)).toList();
      state = items;
    });
  }
}

class TestSQLPage extends HookConsumerWidget {
  final TextEditingController _sqlController = TextEditingController();

  TestSQLPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sqlResult = useState<String>('');

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.testSQLPage),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: TextEditingController(),
              decoration: const InputDecoration(
                labelText: 'Search Users',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) async {
                final users = await ref
                    .read(searchUsersByNameServiceProvider)
                    .searchUsers(value);
                sqlResult.value = users
                    .map((u) =>
                        '${u.firstName} ${u.lastName} (${u.similarityScore.toStringAsFixed(2)})')
                    .join('\n'); // Changed to new line for each user
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _sqlController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.enterSQLQuery,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              minLines: 1,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final db = ref.read(dbProvider);
                final results = await db.execute(_sqlController.text);
                final items = results.map((row) => row.values).toList();
                sqlResult.value = items.toString();
              },
              child: Text(AppLocalizations.of(context)!.executeSQL),
            ),
            Text(sqlResult.value),
          ],
        ),
      ),
    );
  }
}
