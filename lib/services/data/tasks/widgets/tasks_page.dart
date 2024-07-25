import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/data/tasks/cur_tasks/cur_user_tasks_listener_provider.dart';

import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/users/user_db_provider.dart';

class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(curUserTasksListenerProvider);


      final inProgressTasks = ref.watch(
      curUserTasksListenerProvider.select((tasks) => 
        tasks?.where((task) => task.statusEnum == StatusEnum.inProgress).toList() ?? []
      )
    );

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
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TabBarView(
                children: [
                        buildTasksList(ref, filter: (task) => task.statusEnum == StatusEnum.inProgress),
                        buildTasksList(ref, filter: (task) => task.statusEnum == StatusEnum.open),
                        buildTasksList(ref, filter: (task) => task.statusEnum == StatusEnum.finished),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => HandleCreateNewTask(context),
                child: Text('Create New Task'),
              ),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  void HandleCreateNewTask(BuildContext context) {
    // navigate to create task page
    Navigator.pushNamed(context, createTaskRoute);
  }
}

Widget tasksListItem(TaskModel task) {
  
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
    elevation: 4.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (task.description != null) ...[
            SizedBox(height: 8),
            Text(
              task.description!,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(
                    'Status: ${task.statusEnum?.toString().split('.').last ?? 'N/A'}'),
                backgroundColor: Colors.blue[100],
              ),
              Chip(
                label: Text(
                    'Priority: ${task.priorityEnum?.toString().split('.').last ?? 'N/A'}'),
                backgroundColor: Colors.red[100],
              ),
            ],
          ),
          SizedBox(height: 16),
          Text('Due Date: ${task.dueDate?.toIso8601String() ?? 'N/A'}'),
          Text('Created: ${task.createdDate.toIso8601String()}'),
          Text('Last Updated: ${task.lastUpdatedDate.toIso8601String()}'),
          Text('Author: ${task.authorUserId}'),
          // if (task.assignedUserId != null) Text('Assigned to: ${task.assignedUserId}'),
          Text('Team: ${task.parentTeamId}'),
          if (task.parentProjectId != null)
            Text('Project: ${task.parentProjectId}'),         
        ],
      ),
    ),
  );
}

Widget buildTasksList(WidgetRef ref, {required bool Function(TaskModel) filter}) {
  final filteredTasks = ref.watch(
    curUserTasksListenerProvider.select((tasks) => 
      tasks?.where(filter).toList() ?? []
    )
  );

  return ListView.builder(
    itemCount: filteredTasks.length,
    itemBuilder: (context, index) {
      return tasksListItem(filteredTasks[index]);
    },
  );
}
