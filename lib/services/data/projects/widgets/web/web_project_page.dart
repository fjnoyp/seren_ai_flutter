import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/notes_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/notes_list_page.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/action_buttons/edit_project_button.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/action_buttons/update_project_assignees_button.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_page.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/web/web_project_tasks_section.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_user_viewable_tasks_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';

class WebProjectPage extends HookConsumerWidget {
  const WebProjectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = [
      (
        name: AppLocalizations.of(context)!.tasks,
        child: const WebProjectTasksSection()
      ),
      (
        name: AppLocalizations.of(context)!.notes,
        child: const _WebProjectNotesSection()
      ),
    ];

    final isProjectInfoView = useState(false);

    return AsyncValueHandlerWidget(
      value: ref.watch(curSelectedProjectStreamProvider),
      data: (selectedProject) => Padding(
        padding: const EdgeInsets.all(16),
        child: isProjectInfoView.value
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: IconButton(
                      onPressed: () => isProjectInfoView.value = false,
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                  const Expanded(child: _WebProjectInfoView()),
                ],
              )
            : DefaultTabController(
                length: tabs.length,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          selectedProject?.name ?? '',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        IconButton(
                          onPressed: () => isProjectInfoView.value = true,
                          color: Theme.of(context).colorScheme.secondary,
                          iconSize: 18,
                          icon: const Icon(Icons.settings),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const _CurrentProjectReadinessBar(),
                    const SizedBox(height: 16),
                    TabBar(
                      tabs: tabs.map((tab) => Tab(text: tab.name)).toList(),
                    ),
                    Expanded(
                      child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: tabs.map((tab) => tab.child).toList(),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _CurrentProjectReadinessBar extends ConsumerWidget {
  const _CurrentProjectReadinessBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(curSelectedProjectStreamProvider).value!;
    final tasks = ref
        .watch(curUserViewableTasksStreamProvider)
        .valueOrNull
        ?.where((e) => e.parentProjectId == project.id);

    // TODO: improve readiness calculation using tasks estimated duration
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
        Text(
            '${(readiness * 100).toStringAsFixed(2).replaceAll(RegExp(r'\.?0*$'), '')} %'),
      ],
    );
  }
}

// If we make this a public class, we need to change the way we get the project id
// externalizing it
class _WebProjectInfoView extends ConsumerWidget {
  const _WebProjectInfoView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              const ProjectInfoHeader(),
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
              UpdateProjectAssigneesButton(
                  ref.watch(curSelectedProjectIdNotifierProvider)!),
            ],
          ),
        ],
      ),
    );
  }
}

class _WebProjectNotesSection extends ConsumerWidget {
  const _WebProjectNotesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curProjectId = ref.watch(curSelectedProjectIdNotifierProvider);
    return Column(
      children: [
        NoteListByProjectId(curProjectId),
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
