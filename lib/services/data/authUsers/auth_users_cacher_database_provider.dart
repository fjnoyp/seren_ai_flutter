import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/authUsers/models/auth_user_model.dart';
import 'package:seren_ai_flutter/services/data/base_cacher_database_notifier.dart';

final authUsersCacherDatabaseProvider = Provider<BaseLoaderCacheDatabaseNotifier<AuthUserModel>>((ref) {
  return BaseLoaderCacheDatabaseNotifier<AuthUserModel>(
    tableName: 'auth.users',
    fromJson: (json) => AuthUserModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});
