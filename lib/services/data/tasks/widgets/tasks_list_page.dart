import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/data/tasks/cur_tasks/cur_user_viewable_tasks_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/cur_tasks/joined_cur_user_tasks_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';

import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/tasks_list_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_page.dart';
import 'package:seren_ai_flutter/services/data/users/users_read_provider.dart';

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
              Tab(text: 'In Progress'),
              Tab(text: 'Open'),
              Tab(text: 'Finished'),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TabBarView(
                children: [
                  TasksListView(filter: (joinedTask) =>
                          joinedTask.task.status == StatusEnum.inProgress),
                  TasksListView(filter: (joinedTask) =>
                          joinedTask.task.status == StatusEnum.open),
                  TasksListView(filter: (joinedTask) =>
                          joinedTask.task.status == StatusEnum.finished),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => openTaskPage(context, ref, mode: TaskPageMode.create),
                child: Text('Create New Task'),
              ),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
