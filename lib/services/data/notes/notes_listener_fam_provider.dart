import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';

// Family provider that listens to all notes for a given note folder id
final notesListenerFamProvider =
    NotifierProvider.family<NotesListenerFamNotifier, List<NoteModel>?, String>(
        NotesListenerFamNotifier.new);

class NotesListenerFamNotifier
    extends FamilyNotifier<List<NoteModel>?, String> {
  @override
  List<NoteModel>? build(String arg) {
    final noteFolderId = arg;

    final db = ref.read(dbProvider);
    final curUser = ref.read(curAuthStateProvider);

    if (curUser == null) return null;

    final query = '''
      SELECT * 
      FROM notes
      WHERE parent_note_folder_id = '$noteFolderId'
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
