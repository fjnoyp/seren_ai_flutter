import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_db.dart';

final projectsDbProvider = Provider<BaseDb<ProjectModel>>((ref) {
  return BaseDb<ProjectModel>(
    db: ref.watch(dbProvider),
    tableName: 'projects',
    fromJson: (json) => ProjectModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});
