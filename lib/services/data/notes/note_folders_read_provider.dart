import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/base_table_read_db.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_folder_model.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';

final noteFoldersReadProvider = Provider<BaseTableReadDb<NoteFolderModel>>((ref) {
  return BaseTableReadDb<NoteFolderModel>(
    db: ref.watch(dbProvider),
    tableName: 'note_folders',
    fromJson: (json) => NoteFolderModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});

