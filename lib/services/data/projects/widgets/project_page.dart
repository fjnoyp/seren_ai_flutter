import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_org_role_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_editing_project_id_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/action_buttons/delete_project_button.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/action_buttons/edit_project_button.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/action_buttons/update_project_assignees_button.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/form/project_selection_fields.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/users/providers/user_in_project_provider.dart';
import 'package:seren_ai_flutter/services/data/users/widgets/user_avatar.dart';

class ProjectPage extends HookConsumerWidget {
  final EditablePageMode mode;

  const ProjectPage({super.key, required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch selectedProjectServiceProvider in non-create modes
    if (mode != EditablePageMode.create) {
      final projectState = ref.watch(curSelectedProjectStreamProvider);
      if (projectState.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (projectState.hasError || projectState.value == null) {
        // Handle project deletion by other users
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Pop the current project page (route or dialog)
          ref.read(navigationServiceProvider).pop();
          // Remove all project details routes (in case of dialog, we'd need to pop again)
          ref.read(navigationServiceProvider).popUntil((route) =>
              !(route.settings.name?.contains(AppRoutes.projectDetails.name) ??
                  false));
        });
        return const SizedBox.shrink();
      }
    }

    final curEditingProjectId =
        ref.watch(curEditingProjectIdNotifierProvider) ?? '';

    return SingleChildScrollView(
      child: Padding(
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
              ProjectNameField(curEditingProjectId),
              const SizedBox(height: 8),
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  children: [
                    ProjectDescriptionSelectionField(
                        curEditingProjectId, context),
                    const Divider(),
                    ProjectAddressField(curEditingProjectId, context),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (mode == EditablePageMode.create)
                PopScope(
                  onPopInvokedWithResult: (_, result) async {
                    if (result != true) {
                      ref
                          .read(curEditingProjectIdNotifierProvider.notifier)
                          .deleteNewProject();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 32),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: () =>
                            ref.read(navigationServiceProvider).pop(true),
                        child: Text(AppLocalizations.of(context)!.save),
                      ),
                    ),
                  ),
                ),
            ]
          ],
        ),
      ),
    );
  }
}

class ProjectInfoHeader extends ConsumerWidget {
  const ProjectInfoHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueHandlerWidget(
      value: ref.watch(curSelectedProjectStreamProvider),
      data: (project) {
        if (project == null) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              project.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (project.address != null) Text(project.address!),
            const SizedBox(height: 16, width: double.infinity),
            if (project.description != null) Text(project.description!),
          ],
        );
      },
    );
  }
}

class ProjectAssigneesList extends ConsumerWidget {
  const ProjectAssigneesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectId = ref.read(curSelectedProjectStreamProvider).value!.id;
    final projectAssignees =
        ref.watch(usersInProjectProvider(projectId)).valueOrNull ?? [];

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
          itemCount: projectAssignees.length,
          itemBuilder: (context, index) {
            return ListTile(
              dense: true,
              leading: UserAvatar(projectAssignees[index]),
              title: Text(
                  '${projectAssignees[index].firstName} ${projectAssignees[index].lastName}'),
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
  String? projectId,
  EditablePageMode mode = EditablePageMode.readOnly,
}) async {
  assert(projectId != null || mode != EditablePageMode.readOnly);

  switch (mode) {
    case EditablePageMode.readOnly:
      ref
          .read(curSelectedProjectIdNotifierProvider.notifier)
          .setProjectId(projectId!);
      break;
    case EditablePageMode.edit:
      ref
          .read(curEditingProjectIdNotifierProvider.notifier)
          .setProjectId(projectId!);
      break;
    case EditablePageMode.create:
      ref.read(curEditingProjectIdNotifierProvider.notifier).createNewProject();
      break;
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
              EditablePageMode.edit => [
                  DeleteProjectButton(projectId!),
                ],
              EditablePageMode.readOnly => [
                  UpdateProjectAssigneesButton(projectId!),
                  EditProjectButton(projectId),
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
            if (mode == EditablePageMode.edit) DeleteProjectButton(projectId!)
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
