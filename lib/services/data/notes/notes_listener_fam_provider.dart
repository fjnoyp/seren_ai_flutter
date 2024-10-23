import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';

// Family provider that listens to all notes for a given note folder id
final notesListenerFamProvider = NotifierProvider.family<
    NotesListenerFamNotifier,
    List<NoteModel>?,
    String?>(NotesListenerFamNotifier.new);

class NotesListenerFamNotifier
    extends FamilyNotifier<List<NoteModel>?, String?> {
  @override
  List<NoteModel>? build(String? arg) {
    final projectId = arg;

    final db = ref.read(dbProvider);

    // TODO:verify if it doesn't makes more sense to order by updated_at instead of created_at
    final query = projectId == null
        ? '''
      SELECT * 
      FROM notes
      WHERE parent_project_id IS NULL
      ORDER BY created_at DESC
    '''
        : '''
      SELECT * 
      FROM notes
      WHERE parent_project_id = '$projectId'
      ORDER BY created_at DESC
    ''';

    final subscription = db.watch(query).listen((results) {
      List<NoteModel> notes =
          results.map((e) => NoteModel.fromJson(e)).toList();
      state = notes;
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return null;
  }
}
