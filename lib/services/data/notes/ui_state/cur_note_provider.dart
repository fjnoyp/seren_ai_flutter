import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/notes_read_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_states.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final curNoteProvider =
    NotifierProvider<CurNoteNotifier, CurNoteState>(CurNoteNotifier.new);

class CurNoteNotifier extends Notifier<CurNoteState> {
  @override
  CurNoteState build() {
    return InitialCurNoteState();
  }

  void setNewNote(NoteModel note) {
    state = LoadedCurNoteState(note);
  }

  Future<void> setToNewNote(UserModel authorUser, String parentNoteFolderId) async {
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
    return state is LoadedCurNoteState && (state as LoadedCurNoteState).note.name.isNotEmpty;
  }

  void updateNote(NoteModel note) {
    if (state is LoadedCurNoteState) {
      state = LoadedCurNoteState(note);
    }
  }

  // We must showDatePicker and update in same method 
  // As the original ref is invalidated after showDatePicker returns 
  Future<void> pickAndUpdateDate(BuildContext context) async {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      final DateTime now = DateTime.now();
      final DateTime initialDate = loadedState.note.date?.toLocal() ?? now;

      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

      if (pickedDate != null) {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(initialDate),
        );

        if (pickedTime != null) {
          final DateTime pickedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          ).toUtc();

          updateDate(pickedDateTime);
        }
      }
    }
  }

  void updateNoteName(String name) {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      state = LoadedCurNoteState(loadedState.note.copyWith(name: name));
    }
  }

  void updateDate(DateTime? date) {
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
      state = LoadedCurNoteState(loadedState.note.copyWith(description: description));
    }
  }

  void updateActionRequired(String? actionRequired) {
    if (state is LoadedCurNoteState) {
      final loadedState = state as LoadedCurNoteState;
      state = LoadedCurNoteState(loadedState.note.copyWith(actionRequired: actionRequired));
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
  final curNoteState = ref.watch(curNoteProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.note.authorUserId,
    _ => null,
  };
});

final curNoteDateProvider = Provider<DateTime?>((ref) {
  final curNoteState = ref.watch(curNoteProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.note.date,
    _ => null,
  };
});

final curNoteAddressProvider = Provider<String?>((ref) {
  final curNoteState = ref.watch(curNoteProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.note.address,
    _ => null,
  };
});

final curNoteDescriptionProvider = Provider<String?>((ref) {
  final curNoteState = ref.watch(curNoteProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.note.description,
    _ => null,
  };
});

final curNoteActionRequiredProvider = Provider<String?>((ref) {
  final curNoteState = ref.watch(curNoteProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.note.actionRequired,
    _ => null,
  };
});

final curNoteStatusProvider = Provider<String?>((ref) {
  final curNoteState = ref.watch(curNoteProvider);
  return switch (curNoteState) {
    LoadedCurNoteState() => curNoteState.note.status,
    _ => null,
  };
});
