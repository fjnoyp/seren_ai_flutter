import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/note_queries.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository(ref.watch(dbProvider));
});

class NotesRepository extends BaseRepository<NoteModel> {
  const NotesRepository(super.db, {super.primaryTable = 'notes'});

  @override
  NoteModel fromJson(Map<String, dynamic> json) {
    return NoteModel.fromJson(json);
  }

  Stream<List<NoteModel>> watchNotesByProject({
    required String userId,
    String? projectId,
  }) {
    return watch(
      projectId == null
          ? NoteQueries.getUserPersonalNotes
          : NoteQueries.getProjectNotes,
      {
        if (projectId == null) 'user_id': userId else 'project_id': projectId,
      },
    );
  }
}
