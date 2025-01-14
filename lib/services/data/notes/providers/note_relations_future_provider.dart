// Abbreviated linked data loading for displaying notes in a list

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

// Load related note data for displaying in a list
// We're not using them for now as we're not displaying these info in the list

final noteProjectProvider = FutureProvider.autoDispose
    .family<ProjectModel?, NoteModel>((ref, note) async {
  final projectFuture =
      ref.read(projectsRepositoryProvider).getById(note.parentProjectId ?? '');

  return await projectFuture;
});

final noteAuthorProvider =
    FutureProvider.autoDispose.family<UserModel?, NoteModel>((ref, note) async {
  final authorFuture =
      ref.read(usersRepositoryProvider).getById(note.authorUserId);

  return await authorFuture;
});
