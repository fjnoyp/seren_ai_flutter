import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/create_item_bottom_button.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/tasks_list_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TasksListPage extends ConsumerWidget {
  const TasksListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: AppLocalizations.of(context)!.tasksListOpen),
              Tab(text: AppLocalizations.of(context)!.tasksListInProgress),
              Tab(text: AppLocalizations.of(context)!.tasksListFinished),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TabBarView(
                children: [
                  TasksListView(
                      filter: (task) => task.status == StatusEnum.open),
                  TasksListView(
                      filter: (task) => task.status == StatusEnum.inProgress),
                  TasksListView(
                      filter: (task) => task.status == StatusEnum.finished),
                ],
              ),
            ),
          ),
          CreateItemBottomButton(
            onPressed: () async =>
                await ref
                .read(taskNavigationServiceProvider)
                .openTask(mode: EditablePageMode.create),
            buttonText: AppLocalizations.of(context)!.createNewTask,
          ),
        ],
      ),
    );
  }
}
