import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';

final curProjectStateProvider =
    NotifierProvider<CurProjectStateNotifier, AsyncValue<ProjectModel?>>(() {
  return CurProjectStateNotifier();
});

class CurProjectStateNotifier extends Notifier<AsyncValue<ProjectModel?>> {
  @override
  AsyncValue<ProjectModel?> build() {
    return const AsyncValue.data(null);
  }

  void setProject(ProjectModel project) {
    state = AsyncValue.data(project);
  }
}
