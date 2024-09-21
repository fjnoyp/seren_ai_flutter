import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_table_read_db.dart';

final notesReadProvider = Provider<BaseTableReadDb<NoteModel>>((ref) {
  return BaseTableReadDb<NoteModel>(
    db: ref.watch(dbProvider),
    tableName: 'notes',
    fromJson: (json) => NoteModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});
