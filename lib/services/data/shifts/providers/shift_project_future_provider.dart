import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_model.dart';

final shiftProjectFutureProvider =
    FutureProvider.autoDispose.family<ProjectModel?, ShiftModel>(
  (ref, shift) async => await ref
      .watch(projectsRepositoryProvider)
      .getById(shift.parentProjectId),
);
