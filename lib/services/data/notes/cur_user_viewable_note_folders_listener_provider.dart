import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_folder_model.dart';
import 'package:seren_ai_flutter/services/data/projects/cur_user_viewable_projects_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/cur_team/cur_user_viewable_teams_listener_provider.dart';

/// Provide all note folders viewable by the current user
final curUserViewableNoteFoldersListenerProvider =
    NotifierProvider<CurUserViewableNoteFoldersListenerNotifier, List<NoteFolderModel>?>(
        CurUserViewableNoteFoldersListenerNotifier.new);

class CurUserViewableNoteFoldersListenerNotifier extends Notifier<List<NoteFolderModel>?> {
  @override
  List<NoteFolderModel>? build() {
    final watchedCurAuthUser = ref.watch(curAuthUserProvider);

    if (watchedCurAuthUser == null) {
      return null;
    }

    final db = ref.read(dbProvider);

    final curTeams = ref.watch(curUserViewableTeamsListenerProvider);
    final curProjects = ref.watch(curUserViewableProjectsListenerProvider);

    if (curTeams == null && curProjects == null) {
      return [];
    }

    // Get note_folders viewable by the current user
   final query = '''
    SELECT DISTINCT nf.*
    FROM note_folders nf
    WHERE nf.parent_team_id IN (${curTeams?.map((e) => "'${e.id}'").join(',')})
    OR nf.parent_project_id IN (${curProjects?.map((e) => "'${e.id}'").join(',')});
    ''';

    final subscription = db.watch(query).listen((results) {
      List<NoteFolderModel> items = results.map((e) => NoteFolderModel.fromJson(e)).toList();
      state = items;
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return null;
  }
}
