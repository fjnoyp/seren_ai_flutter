import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/note_attachments_service_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/models/joined_note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';

final curNoteStateProvider =
    NotifierProvider<CurNoteStateNotifier, AsyncValue<JoinedNoteModel?>>(() {
  return CurNoteStateNotifier();
});

class CurNoteStateNotifier extends Notifier<AsyncValue<JoinedNoteModel?>> {
  @override
  AsyncValue<JoinedNoteModel?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> setNewNote(JoinedNoteModel joinedNote) async {
    state = AsyncValue.data(joinedNote);
    await ref
        .read(noteAttachmentsServiceProvider.notifier)
        .fetchNoteAttachments(firstLoad: true, noteId: joinedNote.note.id);
  }

  Future<void> setToNewNote({String? parentProjectId}) async {
    state = const AsyncValue.loading();
    try {
      final curUser = ref.read(curUserProvider).value;

      final newNote = NoteModel.defaultNote().copyWith(
        authorUserId: curUser!.id,
        parentProjectId: parentProjectId,
        setAsPersonal: parentProjectId == null,
      );

      state =
          AsyncValue.data(await JoinedNoteModel.fromNoteModel(ref, newNote));
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.empty);
    }
  }
}
