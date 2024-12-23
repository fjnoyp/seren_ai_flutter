import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/base_table_db.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/invite_model.dart';

final invitesDbProvider = Provider<BaseTableDb<InviteModel>>((ref) {
  return BaseTableDb<InviteModel>(
    db: ref.watch(dbProvider),
    tableName: 'invites',
    fromJson: (json) => InviteModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});
