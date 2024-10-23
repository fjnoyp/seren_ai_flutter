import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/selection_field.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';

class BaseProjectSelectionField extends ConsumerWidget {
  final bool enabled;
  final ProviderListenable<ProjectModel?> projectProvider;
  final ProviderListenable<List<ProjectModel>?> selectableProjectsProvider;
  final Function(WidgetRef, ProjectModel?) updateProject;
  final bool isProjectRequired;

  const BaseProjectSelectionField({
    super.key,
    required this.enabled,
    required this.projectProvider,
    required this.selectableProjectsProvider,
    required this.updateProject,
    this.isProjectRequired = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curItemProject = ref.watch(projectProvider);
    final selectableProjects = ref.watch(selectableProjectsProvider);

    return AnimatedModalSelectionField<ProjectModel>(
      labelWidget: const SizedBox(
        width: 60,
        child: Text('Project', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      validator: isProjectRequired
          ? (project) => project == null ? 'Project is required' : null
          : (_) => null,
      valueToString: (project) =>
          project?.name ??
          (isProjectRequired ? 'Select a Project' : 'Personal'),
      enabled: enabled,
      value: curItemProject,
      options: selectableProjects ?? [],
      onValueChanged: (ref, project) {
        updateProject(ref, project);
      },
      isValueRequired: isProjectRequired,
    );
  }
}
