import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/notes_repository.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';

/// Stream provider for notes by project ID
/// If projectId is null, it returns notes with no project (personal notes)
/// Otherwise, it returns notes for the specific project
final notesByProjectStreamProvider =
    StreamProvider.autoDispose.family<List<NoteModel>, String?>(
  (ref, projectId) {
    return CurAuthDependencyProvider.watchStream<List<NoteModel>>(
      ref: ref,
      builder: (userId) {
        // Standard case: Return notes for specific project or personal notes
        return ref.watch(notesRepositoryProvider).watchNotesByProject(
              userId: userId,
              projectId: projectId,
            );
      },
    );
  },
);

/// Stream provider for all notes for the current user
final curUserAllNotesStreamProvider =
    StreamProvider.autoDispose<List<NoteModel>>(
  (ref) {
    return CurAuthDependencyProvider.watchStream<List<NoteModel>>(
      ref: ref,
      builder: (userId) {
        // Standard case: Return notes for specific project or personal notes
        return ref.watch(notesRepositoryProvider).watchAllNotesByUserAndOrg(
              userId: userId,
              orgId: ref.watch(curSelectedOrgIdNotifierProvider)!,
            );
      },
    );
  },
);

/// Stream provider for recently updated notes across all projects and personal notes
/// This provides a chronological view of all notes the user has access to
final recentUpdatedNotesStreamProvider =
    StreamProvider.autoDispose<List<NoteModel>>(
  (ref) {
    return CurAuthDependencyProvider.watchStream<List<NoteModel>>(
      ref: ref,
      builder: (userId) {
        final orgId = ref.watch(curSelectedOrgIdNotifierProvider);
        if (orgId == null) {
          return Stream.value([]);
        }
        return ref
            .watch(notesRepositoryProvider)
            .watchRecentlyUpdatedNotes(
              userId: userId,
              orgId: orgId,
              limit: 100,
            );
      },
    );
  },
);

final curUserDefaultProjectNotesAndPersonalNotesStreamProvider =
    StreamProvider.autoDispose<List<NoteModel>>(
  (ref) {
    return CurAuthDependencyProvider.watchStream<List<NoteModel>>(
      ref: ref,
      builder: (userId) {
        return ref
            .watch(notesRepositoryProvider)
            .watchDefaultProjectNotesAndPersonalNotes(userId: userId);
      },
    );
  },
);
