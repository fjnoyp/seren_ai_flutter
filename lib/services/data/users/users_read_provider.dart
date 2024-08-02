import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_table_read_db.dart';

final usersReadProvider = Provider<BaseTableReadDb<UserModel>>((ref) {
  return BaseTableReadDb<UserModel>(
    db: ref.watch(dbProvider),
    tableName: 'users',
    fromJson: (json) => UserModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});
