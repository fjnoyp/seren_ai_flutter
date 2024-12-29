import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/z_base_table_db.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';

final notesDbProvider = Provider<BaseTableDb<NoteModel>>((ref) {
  return BaseTableDb<NoteModel>(
    db: ref.watch(dbProvider),
    tableName: 'notes',
    fromJson: (json) => NoteModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});
