import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/notes_repository.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final curSelectedNoteIdNotifierProvider =
    NotifierProvider<CurSelectedNoteIdNotifier, String?>(() {
  return CurSelectedNoteIdNotifier();
});

class CurSelectedNoteIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setNoteId(String noteId) => state = noteId;

  void clearNoteId() => state = null;

  Future<void> createNewNote({String? parentProjectId}) async {
    try {
      final curUser = ref.read(curUserProvider).value;
      if (curUser == null) throw Exception('No current user');

      final context =
          ref.read(navigationServiceProvider).navigatorKey.currentContext!;

      final newNote = NoteModel(
        name: AppLocalizations.of(context)?.newNoteDefaultName ?? 'New Note',
        authorUserId: curUser.id,
        parentProjectId: parentProjectId,
        date: DateTime.now().toUtc(),
      );

      await ref.read(notesRepositoryProvider).upsertItem(newNote);

      state = newNote.id;
    } catch (e, __) {
      throw Exception('Failed to create new task: $e');
    }
  }
}
