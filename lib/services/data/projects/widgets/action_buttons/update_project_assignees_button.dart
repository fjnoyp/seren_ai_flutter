import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_assignments_service_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/selected_project_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/form/assignees_from_cur_org_selection_modal.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/users/providers/users_in_project_provider.dart';

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
    final project = ref.read(selectedProjectProvider).value!;
    final projectService =
        ref.read(projectAssignmentsServiceProvider(project.id));
    final assignees =
        ref.watch(usersInProjectProvider(project.id)).valueOrNull ?? [];

    return AssigneesFromCurOrgSelectionModal(
      initialSelectedUsers: assignees,
      onAssigneesChanged: (_, assignees) async =>
          await projectService.updateAssignees(assignees),
    );
  }
}
