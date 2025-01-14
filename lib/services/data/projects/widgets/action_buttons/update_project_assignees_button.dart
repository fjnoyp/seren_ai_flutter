import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_assignments_service_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/selected_project_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/form/project_assignees_selection_modal.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/users/providers/user_in_project_provider.dart';

class UpdateProjectAssigneesButton extends ConsumerWidget {
  const UpdateProjectAssigneesButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: AppLocalizations.of(context)!.updateProjectAssigneesTooltip,
      icon: const Icon(Icons.person_add),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return UpdateProjectAssigneesModal(
              projectId: ref.watch(selectedProjectProvider).value!.id,
            );
          },
        );
      },
    );
  }
}

class UpdateProjectAssigneesModal extends ConsumerWidget {
  const UpdateProjectAssigneesModal({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.read(projectByIdStreamProvider(projectId));
    final projectService =
        ref.read(projectAssignmentsServiceProvider(projectId));
    final assignees =
        ref.watch(usersInProjectProvider(projectId)).valueOrNull ?? [];

    return AsyncValueHandlerWidget(
      value: project,
      data: (project) => project != null
          ? ProjectAssigneesSelectionModal(
              orgId: project.parentOrgId,
              initialSelectedUsers: assignees,
              onAssigneesChanged: (_, assignees) async =>
                  await projectService.updateAssignees(assignees),
            )
          : const Text('Project not found'),
    );
  }
}
