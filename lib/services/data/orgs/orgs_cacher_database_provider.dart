import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/org_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_cacher_database_notifier.dart';

final orgsCacherDatabaseProvider = Provider<BaseLoaderCacheDatabaseNotifier<OrgModel>>((ref) {
  return BaseLoaderCacheDatabaseNotifier<OrgModel>(
    tableName: 'orgs',
    fromJson: (json) => OrgModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});
