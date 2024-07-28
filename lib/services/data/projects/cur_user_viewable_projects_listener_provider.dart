import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/cur_org_id_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/is_cur_user_org_admin_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/cur_user_projects_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';

final curUserViewableProjectsListenerProvider =
    NotifierProvider<CurUserViewableProjectsListenerProvider, List<ProjectModel>?>(
        CurUserViewableProjectsListenerProvider.new);

class CurUserViewableProjectsListenerProvider extends Notifier<List<ProjectModel>?> {
  @override
  List<ProjectModel>? build() {
    final watchedIsCurUserOrgAdmin =
        ref.watch(isCurUserOrgAdminListenerProvider);

    if (watchedIsCurUserOrgAdmin) {
      final watchedCurOrgId = ref.watch(curOrgIdProvider);
      final query =
          "SELECT * FROM projects WHERE parent_org_id = '$watchedCurOrgId'";

      final db = ref.read(dbProvider);

      final subscription = db.watch(query).listen((results) {
        List<ProjectModel> items =
            results.map((e) => ProjectModel.fromJson(e)).toList();
        state = items;
      });

      // Cancel the subscription when the notifier is disposed
      ref.onDispose(() {
        subscription.cancel();
      });
    } else {
      // get all projects that the current user has a role in
      final userProjects = ref.watch(curUserProjectsListenerProvider);
      if (userProjects != null) {
        state = userProjects;
      } else {
        state = [];
      }
    }

    // Return the initial state
    return null;
  }
}
