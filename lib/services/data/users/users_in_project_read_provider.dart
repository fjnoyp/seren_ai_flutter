import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final usersInProjectReadProvider = FutureProvider.family<List<UserModel>, String>((ref, projectId) async {
  final db = ref.watch(dbProvider);

  const query = '''
      SELECT u.* 
      FROM users u
      JOIN user_project_roles upr ON u.id = upr.user_id
      WHERE upr.project_id = ?
    ''';

  final response = await db.execute(query, [projectId]);
  return (response as List).map((e) => UserModel.fromJson(e)).toList();
});
