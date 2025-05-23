import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/common/utils/double_extension.dart';
import 'package:seren_ai_flutter/services/data/budget/widgets/project_budget_section.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/notes_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/project_notes_list.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_org_role_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/action_buttons/edit_project_button.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/action_buttons/update_project_assignees_button.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/action_buttons/upload_file_to_project_button.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_details_page.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_overview/project_tasks_section.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_user_viewable_tasks_stream_provider.dart';
import 'package:seren_ai_flutter/widgets/debug/debug_mode_provider.dart';

class ProjectOverviewPage extends HookConsumerWidget {
  const ProjectOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curSelectedProjectId =
        ref.watch(curSelectedProjectIdNotifierProvider);
    if (curSelectedProjectId == null) {
      return const SizedBox.shrink();
    }

    final curSelectedProject = ref.watch(curSelectedProjectStreamProvider);
    if (curSelectedProject.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (curSelectedProject.hasError) {
      // Handle project deletion by other users
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(navigationServiceProvider).pop();
      });
      return const SizedBox.shrink();
    }

    final isDebugMode = ref.watch(isDebugModeSNP);

    final tabs = [
      if (isWebVersion) ...[
        (
          name: AppLocalizations.of(context)!.board,
          icon: Icons.view_kanban_outlined,
          child: const ProjectTasksSectionWeb(ProjectTasksSectionViewMode.board)
        ),
        (
          name: AppLocalizations.of(context)!.list,
          icon: Icons.list,
          child: const ProjectTasksSectionWeb(ProjectTasksSectionViewMode.list)
        ),
        (
          name: AppLocalizations.of(context)!.ganttChart,
          icon: Icons.segment,
          child: const ProjectTasksSectionWeb(ProjectTasksSectionViewMode.gantt)
        ),
        if (isDebugMode &&
            !CurSelectedProjectIdNotifier.isEverythingId(curSelectedProjectId))
          (
            name: AppLocalizations.of(context)!.budget,
            icon: Icons.money,
            child: ProjectBudgetSection(projectId: curSelectedProjectId)
          ),
      ] else ...[
        (
          name: AppLocalizations.of(context)!.tasks,
          icon: Icons.task,
          child: const ProjectTasksSectionMobile()
        ),
      ],
      (
        name: AppLocalizations.of(context)!.notes,
        icon: Icons.description_outlined,
        child: const _ProjectNotesSection()
      ),
    ];

    final isProjectInfoView = useState(false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 800;
        return Padding(
          padding: isLargeScreen
              ? const EdgeInsets.all(16)
              : const EdgeInsets.all(4),
          child: isProjectInfoView.value &&
                  !CurSelectedProjectIdNotifier.isEverythingId(
                      curSelectedProjectId)
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: isLargeScreen
                          ? const EdgeInsets.only(top: 16)
                          : const EdgeInsets.only(top: 4),
                      child: IconButton(
                        onPressed: () => isProjectInfoView.value = false,
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                    const Expanded(child: _ProjectInfoView()),
                  ],
                )
              : DefaultTabController(
                  length: tabs.length,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isWebVersion)
                        Row(
                          children: [
                            Text(
                              CurSelectedProjectIdNotifier.isEverythingId(
                                      curSelectedProjectId)
                                  ? AppLocalizations.of(context)!
                                      .everythingProjectName
                                  : curSelectedProject.value?.name ?? '',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            if (!CurSelectedProjectIdNotifier.isEverythingId(
                                curSelectedProjectId))
                              IconButton(
                                onPressed: () => isProjectInfoView.value = true,
                                color: Theme.of(context).colorScheme.secondary,
                                iconSize: 18,
                                icon: const Icon(Icons.settings),
                              ),
                            const SizedBox(width: 32),
                            SizedBox(
                              width: 480,
                              child: TabBar(
                                tabs: tabs
                                    .map((tab) => Tab(text: tab.name))
                                    .toList(),
                                dividerColor: Colors.transparent,
                                labelStyle: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Expanded(child: SizedBox.shrink()),
                            if (!CurSelectedProjectIdNotifier.isEverythingId(
                                curSelectedProjectId))
                              UploadFileToProjectButton(curSelectedProjectId),
                          ],
                        ),
                      SizedBox(height: isLargeScreen ? 8 : 3),
                      const _CurrentProjectReadinessBar(),
                      if (!isLargeScreen) ...[
                        const SizedBox(height: 3),
                        TabBar(
                            tabs: tabs
                                .map((tab) => Tab(text: tab.name))
                                .toList()),
                      ],
                      Expanded(
                        child: TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: tabs.map((tab) => tab.child).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _CurrentProjectReadinessBar extends ConsumerWidget {
  const _CurrentProjectReadinessBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(curSelectedProjectStreamProvider).value;
    if (project == null) return const SizedBox.shrink();

    final tasks = ref
        .watch(curUserViewableTasksStreamProvider)
        .valueOrNull
        ?.where((e) => e.parentProjectId == project.id);

    // TODO p4: improve readiness calculation using tasks estimated duration
    final completedTasksCount =
        tasks?.where((e) => e.status == StatusEnum.finished).length ?? 0;
    final totalTasksCount =
        tasks?.where((e) => e.status != StatusEnum.cancelled).toList().length ??
            0;

    final readiness =
        totalTasksCount > 0 ? completedTasksCount / totalTasksCount : 0.0;
    return Row(
      children: [
        Expanded(child: LinearProgressIndicator(value: readiness)),
        const SizedBox(width: 8),
        Text(readiness.toStringAsPercentage()),
      ],
    );
  }
}

// If we make this a public class, we need to change the way we get the project id
// externalizing it
class _ProjectInfoView extends ConsumerWidget {
  const _ProjectInfoView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curUserOrgRole = ref.watch(curUserOrgRoleProvider).valueOrNull;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              const ProjectInfoHeader(),
              if (curUserOrgRole == OrgRole.admin ||
                  curUserOrgRole == OrgRole.editor)
                EditProjectButton(
                    ref.watch(curSelectedProjectIdNotifierProvider)!),
            ],
          ),
          const Divider(height: 32),
          Stack(
            alignment: Alignment.topRight,
            children: [
              ProjectAssigneesList(
                  ref.watch(curSelectedProjectIdNotifierProvider)!),
              if (curUserOrgRole == OrgRole.admin ||
                  curUserOrgRole == OrgRole.editor)
                UpdateProjectAssigneesButton(
                    ref.watch(curSelectedProjectIdNotifierProvider)!),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProjectNotesSection extends ConsumerWidget {
  const _ProjectNotesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curProjectId = ref.watch(curSelectedProjectIdNotifierProvider);
    return Column(
      children: [
        Expanded(child: ProjectNotesList(curProjectId)),
        if (isWebVersion)
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.createNewNote),
            onPressed: () async =>
                ref.read(notesNavigationServiceProvider).openNewNote(
                      parentProjectId: curProjectId,
                    ),
          ),
      ],
    );
  }
}
