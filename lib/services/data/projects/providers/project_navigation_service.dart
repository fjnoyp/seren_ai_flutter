import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/data/common/base_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_org_role_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_editing_project_id_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/action_buttons/delete_project_button.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/action_buttons/project_info_button.dart';
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

  /// For projects, readOnly mode is used to open the project overview page.
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
      EditablePageMode.readOnly => await _getProjectTitle(projectId!) ??
          AppLocalizations.of(context)!.project,
      EditablePageMode.edit => AppLocalizations.of(context)!.updateProject,
      EditablePageMode.create => AppLocalizations.of(context)!.createProject,
    };

    if (mode != EditablePageMode.readOnly && isWebVersion) {
      _showProjectDialog(mode, projectId!, title);
    } else {
      if (projectId != null) {
        _navigateToProjectPage(mode, projectId, title);
      } else {
        // If the initial projectId is null, it means we're in create mode
        // and the projectId was set in the createNewProject method.
        final projectId = ref.read(curEditingProjectIdNotifierProvider);
        _navigateToProjectPage(mode, projectId!, title);
      }
    }
  }

  Future<String?> _getProjectTitle(String projectId) async {
    final project =
        await ref.read(projectsRepositoryProvider).getById(projectId);
    return project?.name;
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
                    UpdateProjectAssigneesButton(projectId),
                    DeleteProjectButton(projectId),
                  ],
                EditablePageMode.readOnly => [
                    ProjectInfoButton(projectId),
                  ],
                _ => null,
              }
            : null;

    if (mode != EditablePageMode.readOnly && !isWebVersion) {
      await ref.read(navigationServiceProvider).navigateTo(
        AppRoutes.projectPage.name,
        arguments: {'title': title, 'mode': mode, 'actions': actions},
      );
    } else {
      await ref.read(navigationServiceProvider).navigateToAndRemoveUntil(
        '${AppRoutes.projectOverview.name}/$projectId',
        // Remove previous ProjectOverviewPage to avoid duplicate pages (if any)
        (route) =>
            route.settings.name?.startsWith(AppRoutes.projectOverview.name) !=
            true,
        arguments: {'title': title, 'mode': mode, 'actions': actions},
      );
    }
  }
}
