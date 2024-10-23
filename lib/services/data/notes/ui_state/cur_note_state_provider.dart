import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/notes/models/joined_note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/notes_read_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_states.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';

final curNoteStateProvider =
    NotifierProvider<CurNoteNotifier, CurNoteState>(CurNoteNotifier.new);

class CurNoteNotifier extends Notifier<CurNoteState> {
  @override
  CurNoteState build() {
    return InitialCurNoteState();
  }

  Future<void> setNewNote(NoteModel note) async {
    state = LoadedCurNoteState(await JoinedNoteModel.fromNoteModel(ref, note));
  }

  Future<void> setToNewNote() async {
    state = LoadingCurNoteState();
    try {
      final curUser =
          (ref.read(curAuthStateProvider) as LoggedInAuthState).user;

      final newNote = NoteModel.defaultNote().copyWith(
        authorUserId: curUser.id,
        parentProjectId: curUser.defaultProjectId,
      );

      state =
          LoadedCurNoteState(await JoinedNoteModel.fromNoteModel(ref, newNote));
    } catch (error) {
      state = ErrorCurNoteState(error: error.toString());
    }
  }

  bool isValidNote() {
    return state is LoadedCurNoteState &&
        (state as LoadedCurNoteState).joinedNote.note.name.isNotEmpty;
  }

  Future<void> updateNote(NoteModel note) async {
    if (state is LoadedCurNoteState) {
      state =
          LoadedCurNoteState(await JoinedNoteModel.fromNoteModel(ref, note));
    }
  }

  void updateNoteName(String name) {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      state = LoadedCurNoteState(loadedState.joinedNote.copyWith(name: name));
    }
  }

  // TODO: we shouldn't be able to freely update date
  // refactor to set date only when creating new note
  void updateDate(DateTime date) {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      state = LoadedCurNoteState(loadedState.joinedNote.copyWith(date: date));
    }
  }

  void updateAddress(String? address) {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      state =
          LoadedCurNoteState(loadedState.joinedNote.copyWith(address: address));
    }
  }

  void updateDescription(String? description) {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      state = LoadedCurNoteState(
          loadedState.joinedNote.copyWith(description: description));
    }
  }

  void updateActionRequired(String? actionRequired) {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      state = LoadedCurNoteState(
          loadedState.joinedNote.copyWith(actionRequired: actionRequired));
    }
  }

  void updateStatus(StatusEnum? status) {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      state =
          LoadedCurNoteState(loadedState.joinedNote.copyWith(status: status));
    }
  }

  void updateParentProject(ProjectModel? project) {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      state = LoadedCurNoteState(loadedState.joinedNote
          .copyWith(project: project, setAsPersonal: project == null));
    }
  }

  Future<void> saveNote() async {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      await ref.read(notesReadProvider).upsertItem(loadedState.joinedNote.note);
    }
  }
}

// Providers for individual fields

final curNoteAuthorProvider = Provider<String?>((ref) {
  final curNoteState = ref.watch(curNoteStateProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.joinedNote.note.authorUserId,
    _ => null,
  };
});

final curNoteDateProvider = Provider<DateTime?>((ref) {
  final curNoteState = ref.watch(curNoteStateProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.joinedNote.note.date,
    _ => null,
  };
});

final curNoteAddressProvider = Provider<String?>((ref) {
  final curNoteState = ref.watch(curNoteStateProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.joinedNote.note.address,
    _ => null,
  };
});

final curNoteDescriptionProvider = Provider<String?>((ref) {
  final curNoteState = ref.watch(curNoteStateProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.joinedNote.note.description,
    _ => null,
  };
});

final curNoteActionRequiredProvider = Provider<String?>((ref) {
  final curNoteState = ref.watch(curNoteStateProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.joinedNote.note.actionRequired,
    _ => null,
  };
});

final curNoteStatusProvider = Provider<StatusEnum?>((ref) {
  final curNoteState = ref.watch(curNoteStateProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.joinedNote.note.status,
    _ => null,
  };
});

final curNoteProjectProvider = Provider<ProjectModel?>((ref) {
  final curNoteState = ref.watch(curNoteStateProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.joinedNote.project,
    _ => null,
  };
});
