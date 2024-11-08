import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/notes/models/joined_note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/joined_notes_repository.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/notes_repository.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';

final curUserNotesProvider =
    StreamProvider.autoDispose.family<List<NoteModel>, String?>(
  (ref, projectId) {
    return CurAuthDependencyProvider.watchStream<List<NoteModel>>(
      ref: ref,
      builder: (userId) {
        return ref.watch(notesRepositoryProvider).watchUserNotes(
              userId: userId,
              projectId: projectId,
            );
      },
    );
  },
);

final curUserJoinedNotesProvider =
    StreamProvider.autoDispose.family<List<JoinedNoteModel>, String?>(
  (ref, projectId) {
    return CurAuthDependencyProvider.watchStream<List<JoinedNoteModel>>(
      ref: ref,
      builder: (userId) {
        return ref.watch(joinedNotesRepositoryProvider).watchUserJoinedNotes(
              userId: userId,
              projectId: projectId,
            );
      },
    );
  },
);
