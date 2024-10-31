import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/create_item_bottom_button.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editablePageModeEnum.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/tasks_list_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_page.dart';
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
                  TasksListView(filter: (joinedTask) =>
                          joinedTask.task.status == StatusEnum.open),
                  TasksListView(filter: (joinedTask) =>
                          joinedTask.task.status == StatusEnum.inProgress),
                  TasksListView(filter: (joinedTask) =>
                          joinedTask.task.status == StatusEnum.finished),
                ],
              ),
            ),
          ),
          CreateItemBottomButton(
            onPressed: () async => await openTaskPage(context, ref, mode: EditablePageMode.create),
            buttonText: AppLocalizations.of(context)!.createNewTask,
          ),      
        ],
      ),
    );
  }
}
