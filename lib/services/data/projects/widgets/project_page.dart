import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_org_roles_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_project_service_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_project_state_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/action_buttons/delete_project_button.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/action_buttons/edit_project_button.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/action_buttons/update_project_assignees_button.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/form/project_selection_fields.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/users/widgets/user_avatar.dart';

class ProjectPage extends HookConsumerWidget {
  final EditablePageMode mode;

  const ProjectPage({super.key, required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mode == EditablePageMode.readOnly) ...[
            const ProjectInfoHeader(),
            const SizedBox(height: 16),
            const ProjectAssigneesList()
          ] else ...[
            ProjectNameField(),
            const SizedBox(height: 8),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                children: [
                  ProjectDescriptionSelectionField(context),
                  const Divider(),
                  ProjectAddressField(context),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 32),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () async {
                    ref.read(curProjectServiceProvider).saveProject();
                  },
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class ProjectInfoHeader extends ConsumerWidget {
  const ProjectInfoHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joinedProject = ref.watch(curProjectStateProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          joinedProject.project.name,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        if (joinedProject.project.address != null)
          Text(joinedProject.project.address!),
        const SizedBox(height: 16, width: double.infinity),
        if (joinedProject.project.description != null)
          Text(joinedProject.project.description!),
      ],
    );
  }
}

class ProjectAssigneesList extends ConsumerWidget {
  const ProjectAssigneesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joinedProject = ref.watch(curProjectStateProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.of(context)!.assignees,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 4),
        ListView.builder(
          shrinkWrap: true,
          itemCount: joinedProject.assignees.length,
          itemBuilder: (context, index) {
            return ListTile(
              dense: true,
              leading: UserAvatar(joinedProject.assignees[index]),
              title: Text(
                  '${joinedProject.assignees[index].firstName} ${joinedProject.assignees[index].lastName}'),
            );
          },
        ),
      ],
    );
  }
}

Future<void> openProjectPage(
  WidgetRef ref,
  BuildContext context, {
  ProjectModel? project,
  EditablePageMode mode = EditablePageMode.readOnly,
}) async {
  assert(project != null || mode != EditablePageMode.readOnly);

  if (mode == EditablePageMode.create) {
    ref.read(curProjectServiceProvider).setToNewProject();
  } else if (mode == EditablePageMode.readOnly) {
    await ref.read(curProjectServiceProvider).loadProject(project!);
  }

  final title = switch (mode) {
    EditablePageMode.readOnly => AppLocalizations.of(context)!.project,
    EditablePageMode.edit => AppLocalizations.of(context)!.updateProject,
    EditablePageMode.create => AppLocalizations.of(context)!.createProject,
  };

  final curUserOrgRole = ref.read(curUserOrgRoleProvider).value;

  final actions =
      (curUserOrgRole == OrgRole.admin || curUserOrgRole == OrgRole.editor)
          ? switch (mode) {
              EditablePageMode.edit => [const DeleteProjectButton()],
              EditablePageMode.readOnly => [
                  const UpdateProjectAssigneesButton(),
                  const EditProjectButton()
                ],
              _ => null,
            }
          : null;

  if (isWebVersion && mode != EditablePageMode.readOnly) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            if (mode == EditablePageMode.edit) const DeleteProjectButton()
          ],
        ),
        content: ProjectPage(mode: mode),
      ),
    );
  } else {
    ref.read(navigationServiceProvider).navigateTo(
      AppRoutes.projectDetails.name,
      arguments: {'title': title, 'mode': mode, 'actions': actions},
    );
  }
}

Future<void> openCreateProjectPage(WidgetRef ref, BuildContext context) async {
  openProjectPage(ref, context, mode: EditablePageMode.create);
}
