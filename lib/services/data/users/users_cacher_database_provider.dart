import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_cacher_database_notifier.dart';

final usersCacherDatabaseProvider = Provider<BaseLoaderCacheDatabaseNotifier<UserModel>>((ref) {
  return BaseLoaderCacheDatabaseNotifier<UserModel>(
    tableName: 'users',
    fromJson: (json) => UserModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});
