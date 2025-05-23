import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/current_route_provider.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/data/common/base_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_org_role_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_editing_project_id_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/action_buttons/delete_project_button.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/action_buttons/open_project_info_button.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/action_buttons/update_project_assignees_button.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_details_page.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_options_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_view_type.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_field_enum.dart';

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
  Future<void> setIdFunction(String id) async {
    await _ensureProjectOrgIsSelected(id);
    ref.read(curSelectedProjectIdNotifierProvider.notifier).setProjectId(id);

    final taskFilterStateNotifier = ref.read(
        taskFilterStateProvider(TaskFilterViewType.projectOverview).notifier);
    
    if (CurSelectedProjectIdNotifier.isEverythingId(id)) {
      taskFilterStateNotifier.removeFilter(TaskFieldEnum.project);
    } else {
      // We only use the name String to show the filter name in the UI
      // but the filter will be hidden in this case
      taskFilterStateNotifier
          .updateFilter(TFProject.byProject(projectId: id, projectName: ""));
    }
  }

  /// For projects, readOnly mode is used to open the project overview page.
  Future<void> openProjectPage({
    String? projectId,
    EditablePageMode mode = EditablePageMode.readOnly,
  }) async {
    assert(projectId != null || mode != EditablePageMode.create);

    switch (mode) {
      case EditablePageMode.readOnly:
        setIdFunction(projectId!);
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
      _navigateToProjectOverviewPage(title);
    } else {
      _openProjectDetailsPage(mode, title);
    }
  }

  Future<void> _ensureProjectOrgIsSelected(String projectId) async {
    // Everything project is not a real project, so we don't need to ensure its org is selected
    if (CurSelectedProjectIdNotifier.isEverythingId(projectId)) return;

    final project = await ref.read(projectByIdStreamProvider(projectId).future);
    if (project == null) {
      throw Exception('Project not found');
    }

    final curSelectedOrgId = ref.read(curSelectedOrgIdNotifierProvider);
    if (project.parentOrgId != curSelectedOrgId) {
      await ref
          .read(curSelectedOrgIdNotifierProvider.notifier)
          .setDesiredOrgId(project.parentOrgId);
    }
  }

  Future<String?> _getProjectTitle(String projectId) async {
    if (CurSelectedProjectIdNotifier.isEverythingId(projectId)) {
      final context = ref.read(navigationServiceProvider).context;
      return AppLocalizations.of(context)!.everythingProjectName;
    }

    final project =
        await ref.read(projectsRepositoryProvider).getById(projectId);
    return project?.name;
  }

  Future<void> _navigateToProjectOverviewPage(String title) async {
    final curUserOrgRole = ref.read(curUserOrgRoleProvider).value;
    final projectId = ref.read(curSelectedProjectIdNotifierProvider);
    if (projectId == null) return;

    final actions =
        (curUserOrgRole == OrgRole.admin || curUserOrgRole == OrgRole.editor) &&
                !CurSelectedProjectIdNotifier.isEverythingId(projectId)
            ? [
                OpenProjectInfoPageButton(projectId),
              ]
            : null;

    return ref.read(navigationServiceProvider).navigateTo(
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
    // This should never happen, but just in case
    if (projectId == null ||
        CurSelectedProjectIdNotifier.isEverythingId(projectId)) {
      return;
    }

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
                children: [
                  Text(title),
                  if (curUserOrgRole == OrgRole.admin ||
                      curUserOrgRole == OrgRole.editor)
                    DeleteProjectButton(projectId),
                ],
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
