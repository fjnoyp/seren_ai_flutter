import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/base_table_db.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/org_model.dart';

final orgsDbProvider = Provider<BaseTableDb<OrgModel>>((ref) {
  return BaseTableDb<OrgModel>(
    db: ref.watch(dbProvider),
    tableName: 'orgs',
    fromJson: (json) => OrgModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});
