import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/notes/cur_user_viewable_note_folders_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/models/joined_note_folder_model.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_folder_model.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/projects_read_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';
import 'package:seren_ai_flutter/services/data/teams/teams_read_provider.dart';

import 'package:collection/collection.dart';

final joinedCurUserViewableNoteFoldersListenerProvider = NotifierProvider<
    JoinedCurUserViewableNoteFoldersListenerNotifier,
    List<JoinedNoteFolderModel>?>(JoinedCurUserViewableNoteFoldersListenerNotifier.new);

class JoinedCurUserViewableNoteFoldersListenerNotifier
    extends Notifier<List<JoinedNoteFolderModel>?> {
  @override
  List<JoinedNoteFolderModel>? build() {
    _listen();
    return null;
  }

  Future<void> _listen() async {
    final watchedCurUserNoteFolders = ref.watch(curUserViewableNoteFoldersListenerProvider);

    if (watchedCurUserNoteFolders == null) {
      return;
    }

    // Fetch teams
    final Set<String> teamIds = watchedCurUserNoteFolders
        .map((noteFolder) => noteFolder.parentTeamId)
        .where((id) => id != null)
        .map((id) => id!)
        .toSet();
    final teams = await ref.watch(teamsReadProvider).getItems(ids: teamIds);

    // Fetch projects
    final Set<String> projectIds = watchedCurUserNoteFolders
        .map((noteFolder) => noteFolder.parentProjectId)
        .where((id) => id != null)
        .map((id) => id!)
        .toSet();
    final projects = await ref.watch(projectsReadProvider).getItems(ids: projectIds);

    // Create joined note folders
    final joinedNoteFolders = watchedCurUserNoteFolders.map((noteFolder) {
      final team = teams.firstWhereOrNull(
        (team) => team.id == noteFolder.parentTeamId,        
      );
      final project = projects.firstWhereOrNull(
        (project) => project.id == noteFolder.parentProjectId,        
      );
      return JoinedNoteFolderModel(
        noteFolder: noteFolder,
        team: team,
        project: project,
      );
    }).toList();

    state = joinedNoteFolders;
  }
}
