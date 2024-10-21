import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/models/joined_note_folder_model.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_folder_model.dart';
import 'package:seren_ai_flutter/services/data/notes/note_folders_read_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/projects_read_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';
import 'package:seren_ai_flutter/services/data/teams/teams_read_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_folder_states.dart';

final curNoteFolderStateProvider =
    NotifierProvider<CurNoteFolderNotifier, CurNoteFolderState>(
        CurNoteFolderNotifier.new);

class CurNoteFolderNotifier extends Notifier<CurNoteFolderState> {
  @override
  CurNoteFolderState build() {
    return InitialCurNoteFolderState();
  }

  void setNewNoteFolder(JoinedNoteFolderModel joinedNoteFolder) {
    state = LoadedCurNoteFolderState(joinedNoteFolder);
  }

  Future<void> setToNewNoteFolder() async {
    state = LoadingCurNoteFolderState();
    try {
      final curUser =
          (ref.read(curAuthStateProvider) as LoggedInAuthState).user;

      final defaultTeam = await ref.read(teamsReadProvider).getItem(eqFilters: [
        {'key': 'id', 'value': curUser.defaultTeamId}
      ]);
      final defaultProject =
          await ref.read(projectsReadProvider).getItem(eqFilters: [
        {'key': 'id', 'value': curUser.defaultProjectId}
      ]);
      final newNoteFolder = NoteFolderModel.defaultNoteFolder().copyWith(
        parentTeamId: defaultTeam?.id,
        parentProjectId: defaultProject?.id,
      );
      state = LoadedCurNoteFolderState(JoinedNoteFolderModel(
        noteFolder: newNoteFolder,
        team: defaultTeam,
        project: defaultProject,
      ));
    } catch (error) {
      state = ErrorCurNoteFolderState(error: error.toString());
    }
  }

  bool isValidNoteFolder() {
    if (state is LoadedCurNoteFolderState) {
      final loadedState = state as LoadedCurNoteFolderState;
      return state is LoadedCurNoteFolderState &&
          loadedState.noteFolder.noteFolder.name.isNotEmpty &&
          loadedState.noteFolder.noteFolder.parentProjectId.isNotEmpty;
    }
    return false;
  }

  void updateNoteFolder(NoteFolderModel noteFolder) {
    if (state is LoadedCurNoteFolderState) {
      final loadedState = state as LoadedCurNoteFolderState;
      state = LoadedCurNoteFolderState(
          loadedState.noteFolder.copyWith(noteFolder: noteFolder));
    }
  }

  void updateNoteFolderName(String name) {
    if (state is LoadedCurNoteFolderState) {
      final loadedState = state as LoadedCurNoteFolderState;
      state = LoadedCurNoteFolderState(loadedState.noteFolder.copyWith(
          noteFolder: loadedState.noteFolder.noteFolder.copyWith(name: name)));
    }
  }

  void updateDescription(String? description) {
    if (state is LoadedCurNoteFolderState) {
      final loadedState = state as LoadedCurNoteFolderState;
      state = LoadedCurNoteFolderState(loadedState.noteFolder.copyWith(
          noteFolder: loadedState.noteFolder.noteFolder
              .copyWith(description: description)));
    }
  }

  void updateAllFields(JoinedNoteFolderModel joinedNoteFolder) {
    state = LoadedCurNoteFolderState(joinedNoteFolder);
  }

  void updateParentProject(ProjectModel? project) {
    if (state is LoadedCurNoteFolderState) {
      final loadedState = state as LoadedCurNoteFolderState;
      state = LoadedCurNoteFolderState(loadedState.noteFolder.copyWith(
          noteFolder: loadedState.noteFolder.noteFolder
              .copyWith(parentProjectId: project?.id),
          project: project));
    }
  }

  void updateParentTeam(TeamModel? team) {
    if (state is LoadedCurNoteFolderState) {
      final loadedState = state as LoadedCurNoteFolderState;
      state = LoadedCurNoteFolderState(loadedState.noteFolder.copyWith(
          noteFolder: loadedState.noteFolder.noteFolder
              .copyWith(parentTeamId: team?.id),
          team: team));
    }
  }

  Future<void> saveNoteFolder() async {
    if (state is LoadedCurNoteFolderState) {
      final loadedState = state as LoadedCurNoteFolderState;
      await ref
          .read(noteFoldersReadProvider)
          .upsertItem(loadedState.noteFolder.noteFolder);
    }
  }
}

// Providers for individual fields

final curNoteFolderNameProvider = Provider<String>((ref) {
  final curNoteFolderState = ref.watch(curNoteFolderStateProvider);
  return switch (curNoteFolderState) {
    LoadedCurNoteFolderState() => curNoteFolderState.noteFolder.noteFolder.name,
    _ => '',
  };
});

final curNoteFolderDescriptionProvider = Provider<String?>((ref) {
  final curNoteFolderState = ref.watch(curNoteFolderStateProvider);
  return switch (curNoteFolderState) {
    LoadedCurNoteFolderState() =>
      curNoteFolderState.noteFolder.noteFolder.description,
    _ => null,
  };
});

final curNoteFolderParentTeamIdProvider = Provider<String?>((ref) {
  final curNoteFolderState = ref.watch(curNoteFolderStateProvider);
  return switch (curNoteFolderState) {
    LoadedCurNoteFolderState() =>
      curNoteFolderState.noteFolder.noteFolder.parentTeamId,
    _ => null,
  };
});

final curNoteFolderParentProjectIdProvider = Provider<String?>((ref) {
  final curNoteFolderState = ref.watch(curNoteFolderStateProvider);
  return switch (curNoteFolderState) {
    LoadedCurNoteFolderState() =>
      curNoteFolderState.noteFolder.noteFolder.parentProjectId,
    _ => null,
  };
});

final curNoteFolderParentProjectProvider = Provider<ProjectModel?>((ref) {
  final curNoteFolderState = ref.watch(curNoteFolderStateProvider);
  return switch (curNoteFolderState) {
    LoadedCurNoteFolderState() => curNoteFolderState.noteFolder.project,
    _ => null,
  };
});

final curNoteFolderParentTeamProvider = Provider<TeamModel?>((ref) {
  final curNoteFolderState = ref.watch(curNoteFolderStateProvider);
  return switch (curNoteFolderState) {
    LoadedCurNoteFolderState() => curNoteFolderState.noteFolder.team,
    _ => null,
  };
});
