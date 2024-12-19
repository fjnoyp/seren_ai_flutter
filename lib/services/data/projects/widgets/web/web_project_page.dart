import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/notes_list_page.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_project_state_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_page.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/web/web_project_tasks_section.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WebProjectPage extends ConsumerWidget {
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
        child: NoteListByProjectId(ref.watch(curProjectStateProvider).project.id)
      ),
      (
        name: AppLocalizations.of(context)!.assignees,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: ProjectAssigneesList(),
        )
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: DefaultTabController(
        length: tabs.length,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ref.watch(curProjectStateProvider).project.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            TabBar(
              tabs: tabs.map((tab) => Tab(text: tab.name)).toList(),
            ),
            Expanded(
              child: TabBarView(
                children: tabs.map((tab) => tab.child).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
