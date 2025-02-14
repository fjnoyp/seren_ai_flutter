import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/current_route_provider.dart';
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
import 'package:seren_ai_flutter/services/data/projects/widgets/action_buttons/open_project_info_button.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/action_buttons/update_project_assignees_button.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_details_page.dart';

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

    if (mode == EditablePageMode.readOnly) {
      await _navigateToProjectOverviewPage(title);
    } else {
      await _openProjectDetailsPage(mode, title);
    }
  }

  Future<String?> _getProjectTitle(String projectId) async {
    final project =
        await ref.read(projectsRepositoryProvider).getById(projectId);
    return project?.name;
  }

  Future<void> _navigateToProjectOverviewPage(String title) async {
    final curUserOrgRole = ref.read(curUserOrgRoleProvider).value;
    final projectId = ref.read(curSelectedProjectIdNotifierProvider);
    if (projectId == null) return;

    final actions =
        (curUserOrgRole == OrgRole.admin || curUserOrgRole == OrgRole.editor)
            ? [
                OpenProjectInfoPageButton(projectId),
              ]
            : null;

    await ref.read(navigationServiceProvider).navigateTo(
          '${AppRoutes.projectOverview.name}/$projectId',
          arguments: {'title': title, 'actions': actions},
          withReplacement: ref
              .read(currentRouteProvider)
              .startsWith(AppRoutes.projectOverview.name),
        );
  }

  Future<void> _openProjectDetailsPage(
    EditablePageMode mode,
    String title,
  ) async {
    final curUserOrgRole = ref.read(curUserOrgRoleProvider).value;
    final projectId = ref.read(curEditingProjectIdNotifierProvider);
    if (projectId == null) return;

    final actions =
        (curUserOrgRole == OrgRole.admin || curUserOrgRole == OrgRole.editor)
            ? [
                UpdateProjectAssigneesButton(projectId),
                DeleteProjectButton(projectId),
              ]
            : null;

    if (isWebVersion) {
      ref.read(navigationServiceProvider).showPopupDialog(
            AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(title), DeleteProjectButton(projectId)],
              ),
              content: ProjectDetailsPage(mode: mode),
            ),
          );
    } else {
      await ref.read(navigationServiceProvider).navigateTo(
        AppRoutes.projectDetails.name,
        arguments: {'title': title, 'mode': mode, 'actions': actions},
      );
    }
  }
}
