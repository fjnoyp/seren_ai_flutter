import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_project_service_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_project_state_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/form/assignees_from_cur_org_selection_modal.dart';

class UpdateProjectAssigneesButton extends ConsumerWidget {
  const UpdateProjectAssigneesButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.person_add),
      onPressed: () {
        final projectService = ref.read(curProjectServiceProvider);
        final projectAssignees = ref.read(curProjectStateProvider).assignees;

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return AssigneesFromCurOrgSelectionModal(
              initialSelectedUsers: projectAssignees,
              onAssigneesChanged: (_, assignees) async =>
                  await projectService.updateAssignees(assignees),
            );
          },
        );
      },
    );
  }
}
