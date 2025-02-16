import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';
import 'package:seren_ai_flutter/services/notifications/fcm_push_notification_service_provider.dart';

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
    final fcmService = ref.watch(fcmPushNotificationServiceProvider);

    final fcmToken = useState<String>('');

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.testSQLPage),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // === DISPLAY FCM TOKEN ===
            SelectableText(
                'FCM Token: ${fcmToken.value ?? "No token available"}'),
            ElevatedButton(
              onPressed: () async {
                await fcmService.initialize();
                fcmToken.value = fcmService.currentToken;
              },
              child: Text('Refresh Token'),
            ),
            const SizedBox(height: 16),
            // === SEARCH USERS TEST ===
            TextField(
              controller: TextEditingController(),
              decoration: const InputDecoration(
                labelText: 'Search Users',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) async {
                final org = ref.read(curSelectedOrgIdNotifierProvider);
                if (org == null) return;

                final users =
                    await ref.read(usersRepositoryProvider).searchUsersByName(
                          searchQuery: value,
                          orgId: org,
                        );
                sqlResult.value = users
                    .map((u) =>
                        '${u.firstName} ${u.lastName} (${u.similarityScore.toStringAsFixed(2)})')
                    .join('\n'); // Changed to new line for each user
              },
            ),
            // ==== SEARCH PROJECTS TEST ===
            TextField(
              controller: TextEditingController(),
              decoration: const InputDecoration(
                labelText: 'Search Projects',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) async {
                final org = ref.read(curSelectedOrgIdNotifierProvider);
                if (org == null) return;

                final projects = await ref
                    .read(projectsRepositoryProvider)
                    .searchProjectsByName(
                      searchQuery: value,
                      orgId: org,
                    );

                sqlResult.value = projects
                    .map((p) =>
                        '${p.name} (${p.similarityScore.toStringAsFixed(2)})')
                    .join('\n');
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
