import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/projects_read_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_project_state_provider.dart';

final curProjectServiceProvider = Provider<CurProjectService>((ref) {
  return CurProjectService(ref);
});

class CurProjectService {
  final Ref ref;
  final AsyncValue<ProjectModel?> _state;
  final CurProjectStateNotifier _notifier;

  CurProjectService(this.ref)
      : _state = ref.watch(curProjectStateProvider),
        _notifier = ref.watch(curProjectStateProvider.notifier);

  void updateProjectName(String name) {
    if (_state.value != null) {
      _notifier.setProject(ProjectModel(
        id: _state.value!.id,
        name: name,
        description: _state.value!.description,
        parentOrgId: _state.value!.parentOrgId,
        address: _state.value!.address,
        createdAt: _state.value!.createdAt,
        updatedAt: DateTime.now().toUtc(),
      ));
    }
  }

  void updateProjectDescription(String? description) {
    if (_state.value != null) {
      _notifier.setProject(ProjectModel(
        id: _state.value!.id,
        name: _state.value!.name,
        description: description,
        parentOrgId: _state.value!.parentOrgId,
        address: _state.value!.address,
        createdAt: _state.value!.createdAt,
        updatedAt: DateTime.now().toUtc(),
      ));
    }
  }

  Future<void> saveProject() async {
    if (_state.value != null) {
      await ref.read(projectsDbProvider).upsertItem(_state.value!);
    }
  }
}

