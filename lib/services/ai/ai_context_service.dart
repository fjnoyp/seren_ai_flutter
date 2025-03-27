import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/notes_repository.dart';

final aiContextServiceProvider =
    Provider<AIContextService>(AIContextService.new);

class AIContextService {
  final Ref ref;

  AIContextService(this.ref);

  Future<String?> getTaskContext(String taskId) async {
    final tasksRepo = ref.read(tasksRepositoryProvider);
    final projectsRepo = ref.read(projectsRepositoryProvider);
    final usersRepo = ref.read(usersRepositoryProvider);

    final task = await tasksRepo.getById(taskId);
    if (task == null) return null;

    final project = await projectsRepo.getById(task.parentProjectId);

    final author = await usersRepo.getById(task.authorUserId);
    final assignees = await usersRepo.getTaskAssignedUsers(taskId: taskId);

    final taskMap = task.toAiReadableMap(
      project: project,
      author: author,
      assignees: assignees,
    );

    return 'CurTask: $taskMap';
  }

  Future<String?> getNoteContext(String noteId) async {
    final notesRepo = ref.read(notesRepositoryProvider);
    final projectsRepo = ref.read(projectsRepositoryProvider);
    final usersRepo = ref.read(usersRepositoryProvider);

    final note = await notesRepo.getById(noteId);
    if (note == null) return null;

    final project = note.parentProjectId != null
        ? await projectsRepo.getById(note.parentProjectId!)
        : null;
    final author = await usersRepo.getById(note.authorUserId);

    final noteMap = note.toAiReadableMap(
      project: project,
      author: author,
    );

    return 'CurNote: $noteMap';
  }
}
