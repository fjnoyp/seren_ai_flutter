import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/notes_read_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_states.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final curNoteStateProvider =
    NotifierProvider<CurNoteNotifier, CurNoteState>(CurNoteNotifier.new);

class CurNoteNotifier extends Notifier<CurNoteState> {
  @override
  CurNoteState build() {
    return InitialCurNoteState();
  }

  void setNewNote(NoteModel note) {
    state = LoadedCurNoteState(note);
  }

  Future<void> setToNewNote(
      UserModel authorUser, String parentNoteFolderId) async {
    state = LoadingCurNoteState();
    try {
      final newNote = NoteModel.defaultNote().copyWith(
        authorUserId: authorUser.id,
        parentNoteFolderId: parentNoteFolderId,
      );
      state = LoadedCurNoteState(newNote);
    } catch (error) {
      state = ErrorCurNoteState(error: error.toString());
    }
  }

  bool isValidNote() {
    return state is LoadedCurNoteState &&
        (state as LoadedCurNoteState).note.name.isNotEmpty;
  }

  void updateNote(NoteModel note) {
    if (state is LoadedCurNoteState) {
      state = LoadedCurNoteState(note);
    }
  }

  void updateNoteName(String name) {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      state = LoadedCurNoteState(loadedState.note.copyWith(name: name));
    }
  }

  // TODO: we shouldn't be able to freely update date
  // refactor to set date only when creating new note
  void updateDate(DateTime date) {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      state = LoadedCurNoteState(loadedState.note.copyWith(date: date));
    }
  }

  void updateAddress(String? address) {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      state = LoadedCurNoteState(loadedState.note.copyWith(address: address));
    }
  }

  void updateDescription(String? description) {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      state = LoadedCurNoteState(
          loadedState.note.copyWith(description: description));
    }
  }

  void updateActionRequired(String? actionRequired) {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      state = LoadedCurNoteState(
          loadedState.note.copyWith(actionRequired: actionRequired));
    }
  }

  void updateStatus(String? status) {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      state = LoadedCurNoteState(loadedState.note.copyWith(status: status));
    }
  }

  void updateAllFields(NoteModel note) {
    state = LoadedCurNoteState(note);
  }

  Future<void> saveNote() async {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      await ref.read(notesReadProvider).upsertItem(loadedState.note);
    }
  }
}

// Providers for individual fields

final curNoteAuthorProvider = Provider<String?>((ref) {
  final curNoteState = ref.watch(curNoteStateProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.note.authorUserId,
    _ => null,
  };
});

final curNoteDateProvider = Provider<DateTime?>((ref) {
  final curNoteState = ref.watch(curNoteStateProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.note.date,
    _ => null,
  };
});

final curNoteAddressProvider = Provider<String?>((ref) {
  final curNoteState = ref.watch(curNoteStateProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.note.address,
    _ => null,
  };
});

final curNoteDescriptionProvider = Provider<String?>((ref) {
  final curNoteState = ref.watch(curNoteStateProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.note.description,
    _ => null,
  };
});

final curNoteActionRequiredProvider = Provider<String?>((ref) {
  final curNoteState = ref.watch(curNoteStateProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.note.actionRequired,
    _ => null,
  };
});

final curNoteStatusProvider = Provider<String?>((ref) {
  final curNoteState = ref.watch(curNoteStateProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.note.status,
    _ => null,
  };
});
