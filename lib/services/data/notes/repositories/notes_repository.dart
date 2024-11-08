import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/note_queries.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository(ref.watch(dbProvider));
});

class NotesRepository extends BaseRepository<NoteModel> {
  const NotesRepository(super.db);

  @override
  Set<String> get watchTables => {'notes', 'projects'};

  @override
  NoteModel fromJson(Map<String, dynamic> json) {
    return NoteModel.fromJson(json);
  }

  Stream<List<NoteModel>> watchUserNotes({
    required String userId,
    String? projectId,
  }) {
    return watch(
        projectId == null
            ? NoteQueries.getUserPersonalNotes
            : NoteQueries.getProjectNotes,
        {
          'user_id': userId,
          if (projectId != null) 'project_id': projectId,
        });
  }

  Future<List<NoteModel>> getUserNotes({
    required String userId,
    String? projectId,
  }) async {
    return get(
        projectId == null
            ? NoteQueries.getUserPersonalNotes
            : NoteQueries.getProjectNotes,
        {
          'user_id': userId,
          if (projectId != null) 'project_id': projectId,
        });
  }
}
