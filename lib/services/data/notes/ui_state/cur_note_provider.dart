import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final curNoteProvider =
    NotifierProvider<CurNoteNotifier, NoteModel>(CurNoteNotifier.new);

class CurNoteNotifier extends Notifier<NoteModel> {
  @override
  NoteModel build() {
    return NoteModel.defaultNote();
  }

  void setNewNote(NoteModel note) {
    state = note;
  }

  void setToNewNote(UserModel authorUser, String parentNoteFolderId) {
    state = NoteModel.defaultNote().copyWith(authorUserId: authorUser.id, parentNoteFolderId: parentNoteFolderId);
  }

  bool isValidNote() {
    return state.name.isNotEmpty;
  }

  void updateNote(NoteModel note) {
    state = note;
  }

  // We must showDatePicker and update in same method 
  // As the original ref is invalidated after showDatePicker returns 
  Future<void> pickAndUpdateDate(BuildContext context) async {

    final DateTime now = DateTime.now();
    final DateTime initialDate = state.date?.toLocal() ?? now;

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

  void updateNoteName(String name) {
    state = state.copyWith(name: name);
  }

  void updateDate(DateTime? date) {
    state = state.copyWith(date: date);
  }

  void updateAddress(String? address) {
    state = state.copyWith(address: address);
  }

  void updateDescription(String? description) {
    state = state.copyWith(description: description);
  }

  void updateActionRequired(String? actionRequired) {
    state = state.copyWith(actionRequired: actionRequired);
  }

  void updateStatus(String? status) {
    state = state.copyWith(status: status);
  }

  void updateAllFields(NoteModel note) {
    state = note;
  }
}

// Providers for individual fields

final curNoteAuthorProvider = Provider<String>((ref) {
  return ref.watch(curNoteProvider.select((state) => 
    state.authorUserId));
});

final curNoteDateProvider = Provider<DateTime?>((ref) {
  return ref.watch(curNoteProvider.select((state) => state.date));
});

final curNoteAddressProvider = Provider<String?>((ref) {
  return ref.watch(curNoteProvider.select((state) => state.address));
});

final curNoteDescriptionProvider = Provider<String?>((ref) {
  return ref.watch(curNoteProvider.select((state) => state.description));
});

final curNoteActionRequiredProvider = Provider<String?>((ref) {
  return ref.watch(curNoteProvider.select((state) => state.actionRequired));
});

final curNoteStatusProvider = Provider<String?>((ref) {
  return ref.watch(curNoteProvider.select((state) => state.status));
});
