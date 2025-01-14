import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';

final projectByIdStreamProvider =
    StreamProvider.autoDispose.family<ProjectModel?, String>(
  (ref, projectId) =>
      ref.watch(projectsRepositoryProvider).watchById(projectId),
);
