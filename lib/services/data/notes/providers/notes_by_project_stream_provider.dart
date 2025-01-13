import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/notes_repository.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';

// userId is only necessary for personal notes
final notesByProjectStreamProvider =
    StreamProvider.autoDispose.family<List<NoteModel>, String?>(
  (ref, projectId) {
    return CurAuthDependencyProvider.watchStream<List<NoteModel>>(
      ref: ref,
      builder: (userId) {
        return ref.watch(notesRepositoryProvider).watchNotesByProject(
              userId: userId,
              projectId: projectId,
            );
      },
    );
  },
);
