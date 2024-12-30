import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_assignments_service_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/selected_project_service_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/form/assignees_from_cur_org_selection_modal.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
            return const UpdateProjectAssigneesModal();
          },
        );
      },
    );
  }
}

class UpdateProjectAssigneesModal extends ConsumerWidget {
  const UpdateProjectAssigneesModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joinedProject = ref.read(selectedProjectServiceProvider).value!;
    final projectService =
        ref.read(projectAssignmentsServiceProvider(joinedProject.project.id));

    return AssigneesFromCurOrgSelectionModal(
      initialSelectedUsers: joinedProject.assignees,
      onAssigneesChanged: (_, assignees) async =>
          await projectService.updateAssignees(assignees),
    );
  }
}
