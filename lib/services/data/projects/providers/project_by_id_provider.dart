import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';

final projectByIdProvider =
    FutureProvider.autoDispose.family<ProjectModel?, String>(
  (ref, projectId) async =>
      await ref.watch(projectsRepositoryProvider).getById(projectId),
);
