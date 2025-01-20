import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/notes_repository.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';

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

      final newNote = NoteModel.defaultNote().copyWith(
        authorUserId: curUser.id,
        parentProjectId: parentProjectId,
        setAsPersonal: parentProjectId == null,
      );

      await ref.read(notesRepositoryProvider).upsertItem(newNote);

      state = newNote.id;
    } catch (e, __) {
      throw Exception('Failed to create new task: $e');
    }
  }

  Future<Map<String, dynamic>> toReadableMap() async {
    if (state == null) return {'error': 'No editing note'};

    final curNote = await ref.read(notesRepositoryProvider).getById(state!);
    if (curNote == null) return {'error': 'Note not found'};

    final curAuthor =
        await ref.read(usersRepositoryProvider).getById(curNote.authorUserId);
    final curProject = curNote.parentProjectId != null
        ? await ref
            .read(projectsRepositoryProvider)
            .getById(curNote.parentProjectId!)
        : null;

    return {
      'note': {
        'name': curNote.name,
        'description': curNote.description,
        'status': curNote.status,
        'date': curNote.date?.toIso8601String(),
        'address': curNote.address,
        'action_required': curNote.actionRequired,
      },
      'author': curAuthor?.email ?? 'Unknown',
      'project': curProject?.name ?? 'No Project',
    };
  }
}
