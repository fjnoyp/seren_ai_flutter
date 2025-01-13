import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/selection_field.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';

class BaseProjectSelectionField extends ConsumerWidget {
  final bool isEditable;
  final ProviderListenable<String?> projectIdProvider;
  final AutoDisposeStreamProvider<List<ProjectModel>?>
      selectableProjectsProvider;
  final Function(WidgetRef, ProjectModel?) updateProject;
  final bool isProjectRequired;

  const BaseProjectSelectionField({
    super.key,
    required this.isEditable,
    required this.projectIdProvider,
    required this.selectableProjectsProvider,
    required this.updateProject,
    this.isProjectRequired = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectId = ref.watch(projectIdProvider);
    final selectableProjectsAsync = ref.watch(selectableProjectsProvider);

    // Use FutureBuilder to handle the async project loading
    return FutureBuilder<ProjectModel?>(
      // Fetch project whenever ID changes
      future: projectId != null
          ? ref.read(projectsRepositoryProvider).getById(projectId)
          : Future.value(null),
      builder: (context, projectSnapshot) {
        // Handle loading states
        if (projectSnapshot.connectionState == ConnectionState.waiting ||
            selectableProjectsAsync.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle error states
        if (projectSnapshot.hasError) {
          return Text('Error loading project: ${projectSnapshot.error}');
        }
        if (selectableProjectsAsync.hasError) {
          return Text(
              'Error loading projects: ${selectableProjectsAsync.error}');
        }

        final project = projectSnapshot.data;
        final selectableProjects = selectableProjectsAsync.valueOrNull ?? [];

        return isEditable
            ? AnimatedModalSelectionField<ProjectModel>(
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
                value: project,
                options: selectableProjects,
                onValueChanged: (ref, project) => updateProject(ref, project),
                isValueRequired: isProjectRequired,
              )
            : Text(project?.name ?? '');
      },
    );
  }
}
