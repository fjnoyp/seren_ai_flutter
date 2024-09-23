import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/notes/models/joined_note_folder_model.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_folder_model.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';

final curNoteFolderProvider =
    NotifierProvider<CurNoteFolderNotifier, JoinedNoteFolderModel>(CurNoteFolderNotifier.new);

class CurNoteFolderNotifier extends Notifier<JoinedNoteFolderModel> {
  @override
  JoinedNoteFolderModel build() {
    return JoinedNoteFolderModel.empty();
  }

  void setNewNoteFolder(JoinedNoteFolderModel joinedNoteFolder) {
    state = joinedNoteFolder;
  }

  void setToNewNoteFolder() {
    state = JoinedNoteFolderModel.empty();
  }

  bool isValidNoteFolder() {
    return state.noteFolder.name.isNotEmpty && state.noteFolder.parentProjectId.isNotEmpty;
  }

  void updateNoteFolder(NoteFolderModel noteFolder) {
    state = state.copyWith(noteFolder: noteFolder);
  }

  void updateNoteFolderName(String name) {
    state = state.copyWith(noteFolder: state.noteFolder.copyWith(name: name));
  }

  void updateDescription(String? description) {
    state = state.copyWith(noteFolder: state.noteFolder.copyWith(description: description));
  }

  void updateAllFields(JoinedNoteFolderModel joinedNoteFolder) {
    state = joinedNoteFolder;
  }

  void updateParentProject(ProjectModel? project) {
    state = state.copyWith(
      noteFolder: state.noteFolder.copyWith(parentProjectId: project?.id),
      project: project
    );
  }

  void updateParentTeam(TeamModel? team) {
    state = state.copyWith(
      noteFolder: state.noteFolder.copyWith(parentTeamId: team?.id),
      team: team
    );
  }
}

// Providers for individual fields

final curNoteFolderNameProvider = Provider<String>((ref) {
  return ref.watch(curNoteFolderProvider.select((state) => state.noteFolder.name));
});

final curNoteFolderDescriptionProvider = Provider<String?>((ref) {
  return ref.watch(curNoteFolderProvider.select((state) => state.noteFolder.description));
});

final curNoteFolderParentTeamIdProvider = Provider<String?>((ref) {
  return ref.watch(curNoteFolderProvider.select((state) => state.noteFolder.parentTeamId));
});

final curNoteFolderParentProjectIdProvider = Provider<String>((ref) {
  return ref.watch(curNoteFolderProvider.select((state) => state.noteFolder.parentProjectId));
});

final curNoteFolderParentProjectProvider = Provider<ProjectModel?>((ref) {
  return ref.watch(curNoteFolderProvider.select((state) => state.project));
});

final curNoteFolderParentTeamProvider = Provider<TeamModel?>((ref) {
  return ref.watch(curNoteFolderProvider.select((state) => state.team));
});
