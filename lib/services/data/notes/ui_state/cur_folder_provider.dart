import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_folder_model.dart';

final curNoteFolderProvider =
    NotifierProvider<CurNoteFolderNotifier, NoteFolderModel>(CurNoteFolderNotifier.new);

class CurNoteFolderNotifier extends Notifier<NoteFolderModel> {
  @override
  NoteFolderModel build() {
    return NoteFolderModel.defaultNoteFolder();
  }

  void setNewNoteFolder(NoteFolderModel noteFolder) {
    state = noteFolder;
  }

  void setToNewNoteFolder() {
    state = NoteFolderModel.defaultNoteFolder();
  }

  bool isValidNoteFolder() {
    return state.name.isNotEmpty;
  }

  void updateNoteFolder(NoteFolderModel noteFolder) {
    state = noteFolder;
  }

  void updateNoteFolderName(String name) {
    state = state.copyWith(name: name);
  }

  void updateDescription(String? description) {
    state = state.copyWith(description: description);
  }

  void updateAllFields(NoteFolderModel noteFolder) {
    state = noteFolder;
  }
}

// Providers for individual fields

final curNoteFolderNameProvider = Provider<String>((ref) {
  return ref.watch(curNoteFolderProvider.select((state) => state.name));
});

final curNoteFolderDescriptionProvider = Provider<String?>((ref) {
  return ref.watch(curNoteFolderProvider.select((state) => state.description));
});

final curNoteFolderParentTeamIdProvider = Provider<String?>((ref) {
  return ref.watch(curNoteFolderProvider.select((state) => state.parentTeamId));
});

final curNoteFolderParentProjectIdProvider = Provider<String>((ref) {
  return ref.watch(curNoteFolderProvider.select((state) => state.parentProjectId));
});
