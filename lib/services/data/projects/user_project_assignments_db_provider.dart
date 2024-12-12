import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/base_table_db.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/user_project_assignment_model.dart';

final userProjectAssignmentsDbProvider =
    Provider<BaseTableDb<UserProjectAssignmentModel>>((ref) {
  return BaseTableDb<UserProjectAssignmentModel>(
    db: ref.watch(dbProvider),
    tableName: 'user_project_assignments',
    fromJson: (json) => UserProjectAssignmentModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});
