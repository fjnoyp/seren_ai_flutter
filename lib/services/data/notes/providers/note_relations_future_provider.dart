// Abbreviated linked data loading for displaying notes in a list

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

// Load related note data for displaying in a list
final noteRelationsProvider = FutureProvider.autoDispose
    .family<NoteListItemDetails, NoteModel>((ref, note) async {
  final Future<ProjectModel?> projectFuture =
      ref.watch(projectsRepositoryProvider).getById(note.parentProjectId ?? '');

  final Future<UserModel?> authorFuture =
      ref.watch(usersRepositoryProvider).getById(note.authorUserId);

  final project = await projectFuture;
  final author = await authorFuture;

  return NoteListItemDetails(
    project: project,
    author: author,
  );
});

class NoteListItemDetails {
  final ProjectModel? project;
  final UserModel? author;

  NoteListItemDetails({
    this.project,
    this.author,
  });
}
