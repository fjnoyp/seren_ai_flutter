import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/common/base_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_org_role_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_editing_project_id_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/action_buttons/delete_project_button.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/action_buttons/edit_project_button.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/action_buttons/update_project_assignees_button.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_page.dart';

final projectNavigationServiceProvider =
    Provider<ProjectNavigationService>((ref) {
  return ProjectNavigationService(ref);
});

class ProjectNavigationService extends BaseNavigationService {
  ProjectNavigationService(super.ref);

  @override
  NotifierProvider get idNotifierProvider =>
      curSelectedProjectIdNotifierProvider;

  @override
  void setIdFunction(String id) =>
      ref.read(curSelectedProjectIdNotifierProvider.notifier).setProjectId(id);

  Future<void> openProjectPage({
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
        ref
            .read(curEditingProjectIdNotifierProvider.notifier)
            .createNewProject();
        break;
    }

    final context = ref.read(navigationServiceProvider).context;

    final title = switch (mode) {
      EditablePageMode.readOnly => AppLocalizations.of(context)!.project,
      EditablePageMode.edit => AppLocalizations.of(context)!.updateProject,
      EditablePageMode.create => AppLocalizations.of(context)!.createProject,
    };

    if (mode != EditablePageMode.readOnly) {
      _showProjectDialog(mode, projectId!, title);
    } else {
      _navigateToProjectPage(mode, projectId!, title);
    }
  }

  Future<void> _showProjectDialog(
    EditablePageMode mode,
    String projectId,
    String title,
  ) async {
    ref.read(navigationServiceProvider).showPopupDialog(
          AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title),
                if (mode == EditablePageMode.edit)
                  DeleteProjectButton(projectId)
              ],
            ),
            content: ProjectPage(mode: mode),
          ),
        );
  }

  Future<void> _navigateToProjectPage(
    EditablePageMode mode,
    String projectId,
    String title,
  ) async {
    final curUserOrgRole = ref.read(curUserOrgRoleProvider).value;

    final actions =
        (curUserOrgRole == OrgRole.admin || curUserOrgRole == OrgRole.editor)
            ? switch (mode) {
                EditablePageMode.edit => [
                    DeleteProjectButton(projectId),
                  ],
                EditablePageMode.readOnly => [
                    UpdateProjectAssigneesButton(projectId),
                    EditProjectButton(projectId),
                  ],
                _ => null,
              }
            : null;

    await ref.read(navigationServiceProvider).navigateToAndRemoveUntil(
      '${AppRoutes.projectDetails.name}/$projectId',
      // Remove previous ProjectPage to avoid duplicate project pages (if any)
      (route) =>
          route.settings.name?.startsWith(AppRoutes.projectDetails.name) !=
          true,
      arguments: {'title': title, 'mode': mode, 'actions': actions},
    );
  }
}
