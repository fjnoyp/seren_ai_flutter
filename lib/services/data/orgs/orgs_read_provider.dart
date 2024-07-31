import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/org_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_read_db.dart';

final orgsReadProvider = Provider<BaseReadDb<OrgModel>>((ref) {
  return BaseReadDb<OrgModel>(
    db: ref.watch(dbProvider),
    tableName: 'orgs',
    fromJson: (json) => OrgModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});
