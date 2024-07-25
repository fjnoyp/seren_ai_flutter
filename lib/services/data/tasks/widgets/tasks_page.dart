import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/data/tasks/cur_tasks/cur_user_tasks_listener_provider.dart';

import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'In Progress'),
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TabBarView(
                children: [
                  InProgressTasks(),
                  UpcomingTasks(),
                  CompletedTasks(),
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

Widget taskPreview(TaskModel task) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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

class InProgressTasks extends ConsumerWidget {
  const InProgressTasks({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('InProgressTasks: build');
    final tasks = ref.watch(curUserTasksListenerProvider);
    print('InProgressTasks: tasks: $tasks');

    // TODO: filter on team - currently cross team tasks shown

    return Container(
      color: Colors.red,
      child: tasks == null
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? const Center(child: Text('No tasks available'))
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(task.name),
                      subtitle: Text(task.description ?? ''),
                    );
                  },
                ),
    );
  }
}

class UpcomingTasks extends StatelessWidget {
  const UpcomingTasks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace with your actual task data
    final tasks = ['Task 4', 'Task 5', 'Task 6'];

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(tasks[index]),
        );
      },
    );
  }
}

class CompletedTasks extends StatelessWidget {
  const CompletedTasks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace with your actual task data
    final tasks = ['Task 7', 'Task 8', 'Task 9'];

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(tasks[index]),
        );
      },
    );
  }
}
