import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/common/utils/string_similarity_extension.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/note_queries.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository(ref.watch(dbProvider), ref);
});

class NotesRepository extends BaseRepository<NoteModel> {
  final Ref ref;

  const NotesRepository(super.db, this.ref, {super.primaryTable = 'notes'});

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

  // TODO p3: personal notes should probably be org-specific
  Stream<List<NoteModel>> watchAllNotesByUserAndOrg({
    required String userId,
    required String orgId,
  }) {
    return watch(
      NoteQueries.getAllNotesByUserAndOrg,
      {
        'user_id': userId,
        'org_id': orgId,
      },
    );
  }

  Future<List<NoteModel>> getAllNotesByUserAndOrg({
    required String userId,
    required String orgId,
  }) async {
    return get(
      NoteQueries.getAllNotesByUserAndOrg,
      {
        'user_id': userId,
        'org_id': orgId,
      },
    );
  }

  Stream<List<NoteModel>> watchDefaultProjectNotesAndPersonalNotes({
    required String userId,
  }) {
    return watch(
      NoteQueries.getDefaultProjectNotesAndPersonalNotes,
      {
        'user_id': userId,
      },
    );
  }

  Future<void> updateNoteName(String noteId, String? name) async {
    if (name == null) return;

    await updateField(
      noteId,
      'name',
      name,
    );
  }

  Future<void> updateNoteDate(String noteId, DateTime? date) async {
    await updateField(
      noteId,
      'date',
      date?.toIso8601String(),
    );
  }

  Future<void> updateNoteAddress(String noteId, String? address) async {
    await updateField(
      noteId,
      'address',
      address,
    );
  }

  Future<void> updateNoteDescription(String noteId, String? description) async {
    await updateField(
      noteId,
      'description',
      description,
    );
  }

  Future<void> updateNoteActionRequired(
      String noteId, String? actionRequired) async {
    await updateField(
      noteId,
      'action_required',
      actionRequired,
    );
  }

  Future<void> updateNoteStatus(String noteId, StatusEnum? status) async {
    if (status == null) return;

    await updateField(
      noteId,
      'status',
      status.name,
    );
  }

  Future<void> updateNoteParentProjectId(
      String noteId, String? projectId) async {
    await updateField(
      noteId,
      'parent_project_id',
      projectId,
    );
  }

  /// Stream of recently updated notes across all projects the user has access to.
  /// This gives the user a unified view of their most recent activity.
  Stream<List<NoteModel>> watchRecentlyUpdatedNotes({
    required String userId,
    required String orgId,
    int limit = 20,
  }) {
    return watch(
      NoteQueries.recentlyUpdatedNotesQuery,
      {
        'user_id': userId,
        'org_id': orgId,
        'limit': limit,
      },
      triggerOnTables: {
        'notes',
        'projects',
      },
    );
  }

  /// Gets the parent organization ID for a note
  /// This is determined by the note's project's organization
  Future<String?> getNoteParentOrgId(String noteId) async {
    // For notes with a project, get the org ID from the project
    final projectQuery = '''
      SELECT p.parent_org_id
      FROM notes n
      JOIN projects p ON n.parent_project_id = p.id
      WHERE n.id = ?
    ''';

    final result = await db.execute(projectQuery, [noteId]);
    if (result.isNotEmpty) {
      return result.first['parent_org_id'] as String?;
    }

    // For personal notes (without a project), the org ID is null
    return null;
  }

  Future<List<NoteModel>> searchNotesByName({
    required String searchQuery,
    required String orgId,
    double similarityThreshold = 0.6,
    int limit = 5,
  }) async {
    // TODO p3: implement db based search
    //return get(NoteQueries.searchNotesByNameQuery, {'search_query': searchQuery, 'org_id': orgId});

    final curAuthState = ref.read(curUserProvider);

    if (curAuthState.value == null) throw Exception('No auth');

    // TODO p2: we only get personal notes for now ...
    final allNotes = await getAllNotesByUserAndOrg(
      userId: curAuthState.value!.id,
      orgId: orgId,
    );

    // Calculate similarity scores and sort
    final notesWithScores = allNotes
        .map((note) {
          final similarity = note.name.similarity(searchQuery);
          return (note, similarity);
        })
        .where((tuple) => tuple.$2 >= similarityThreshold)
        .toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));

    // Return top matches
    return notesWithScores.take(limit).map((tuple) => tuple.$1).toList();
  }
}
