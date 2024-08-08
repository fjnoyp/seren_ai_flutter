import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final usersInProjectListenerProvider = NotifierProvider.family<UsersInProjectListenerNotifier, List<UserModel>?, String>(
  UsersInProjectListenerNotifier.new
);

class UsersInProjectListenerNotifier extends FamilyNotifier<List<UserModel>?, String> {
  @override
  List<UserModel>? build(String arg) {
    final projectId = arg;
    
    final db = ref.read(dbProvider);

    final query = '''
      SELECT u.* 
      FROM users u
      JOIN user_project_roles upr ON u.id = upr.user_id
      WHERE upr.project_id = '$projectId'
    ''';

    final subscription = db.watch(query).listen((results) {
      List<UserModel> users = results.map((e) => UserModel.fromJson(e)).toList();
      state = users;
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return null;
  }
}
