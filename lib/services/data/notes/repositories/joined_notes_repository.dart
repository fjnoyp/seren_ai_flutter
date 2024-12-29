import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/models/joined_note_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/note_queries.dart';

final joinedNotesRepositoryProvider = Provider<JoinedNotesRepository>((ref) {
  return JoinedNotesRepository(ref.watch(dbProvider));
});

class JoinedNotesRepository extends BaseRepository<JoinedNoteModel> {
  const JoinedNotesRepository(super.db);

  @override
  Set<String> get REMOVEwatchTables => {'notes', 'projects', 'users'};

  @override
  JoinedNoteModel fromJson(Map<String, dynamic> json) {
    final decodedJson = json.map((key, value) =>
        (key == 'note' || key == 'author_user' || key == 'project') &&
                value != null
            ? MapEntry(key, jsonDecode(value))
            : MapEntry(key, value));

    return JoinedNoteModel.fromJson(decodedJson);
  }

  Stream<List<JoinedNoteModel>> watchUserJoinedNotes({
    required String userId,
    String? projectId,
  }) {
    return watch(
      projectId == null
          ? NoteQueries.getUserPersonalJoinedNotes
          : NoteQueries.getProjectJoinedNotes,
      {
        projectId != null ? 'project_id' : 'user_id': projectId ?? userId,
      },
    );
  }

  Future<List<JoinedNoteModel>> getUserJoinedNotes({
    required String userId,
    String? projectId,
  }) async {
    return get(
      projectId == null
          ? NoteQueries.getUserPersonalJoinedNotes
          : NoteQueries.getProjectJoinedNotes,
      {
        projectId != null ? 'project_id' : 'user_id': projectId ?? userId,
      },
    );
  }

  Future<JoinedNoteModel> getJoinedNote(String noteId) async {
    return getSingle(NoteQueries.getJoinedNote, {'note_id': noteId});
  }
}
