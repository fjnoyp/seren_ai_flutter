import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/notes/joined_cur_user_viewable_note_folders_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/models/joined_note_folder_model.dart';

import 'package:collection/collection.dart';

final joinedNoteFolderByIdProvider = Provider.family<JoinedNoteFolderModel?, String>((ref, id) {
  final allFolders = ref.watch(joinedCurUserViewableNoteFoldersListenerProvider);
  return allFolders?.firstWhereOrNull((folder) => folder.noteFolder.id == id);
});
