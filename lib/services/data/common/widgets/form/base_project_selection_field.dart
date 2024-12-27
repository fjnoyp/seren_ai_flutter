import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/selection_field.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';

class BaseProjectSelectionField extends ConsumerWidget {
  final bool isEditable;
  final ProviderListenable<ProjectModel?> projectProvider;
  final AutoDisposeStreamProvider<List<ProjectModel>?> selectableProjectsProvider;
  final Function(WidgetRef, ProjectModel?) updateProject;
  final bool isProjectRequired;

  const BaseProjectSelectionField({
    super.key,
    required this.isEditable,
    required this.projectProvider,
    required this.selectableProjectsProvider,
    required this.updateProject,
    this.isProjectRequired = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curItemProject = ref.watch(projectProvider);
    final selectableProjects = ref.watch(selectableProjectsProvider);

    return isEditable ? AnimatedModalSelectionField<ProjectModel>(
      labelWidget: SizedBox(
        width: 60,
        child: Text(
          AppLocalizations.of(context)!.project,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      validator: isProjectRequired
          ? (project) => project == null 
              ? AppLocalizations.of(context)!.projectIsRequired 
              : null
          : (_) => null,
      valueToString: (project) =>
          project?.name ??
          (isProjectRequired 
              ? AppLocalizations.of(context)!.selectAProject 
              : AppLocalizations.of(context)!.personal),
      enabled: isEditable,
      value: curItemProject,
      options: selectableProjects.when(
        data: (data) => data ?? [],
        error: (error, _) => throw error,
        loading: () => [],
      ),
      onValueChanged: (ref, project) {
        updateProject(ref, project);
      },
      isValueRequired: isProjectRequired,
    ) : Text(curItemProject?.name ?? '');
  }
}
