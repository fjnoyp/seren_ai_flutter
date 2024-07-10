import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tasks_listener_database_provider.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
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
            child: TabBarView(
              children: [
                InProgressTasks(),
                UpcomingTasks(),
                CompletedTasks(),
              ],
            ),
          ),
        ],
      ),
    );
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
                label: Text('Status: ${task.statusEnum?.toString().split('.').last ?? 'N/A'}'),
                backgroundColor: Colors.blue[100],
              ),
              Chip(
                label: Text('Priority: ${task.priorityEnum?.toString().split('.').last ?? 'N/A'}'),
                backgroundColor: Colors.red[100],
              ),
            ],
          ),
          SizedBox(height: 16),
          Text('Due Date: ${task.dueDate?.toIso8601String() ?? 'N/A'}'),
          Text('Created: ${task.createdDate.toIso8601String()}'),
          Text('Last Updated: ${task.lastUpdatedDate.toIso8601String()}'),
          Text('Author: ${task.authorUserId}'),
          if (task.assignedUserId != null) Text('Assigned to: ${task.assignedUserId}'),
          Text('Team: ${task.parentTeamId}'),
          if (task.parentProjectId != null) Text('Project: ${task.parentProjectId}'),
          if (task.estimatedDuration != null) Text('Estimated Duration: ${task.estimatedDuration} mins'),
          if (task.listDurations != null) ...[
            SizedBox(height: 16),
            Text('Durations:'),
            for (var duration in task.listDurations!)
              Text('${duration.keys.first}: ${duration.values.first.toIso8601String()}'),
          ],
        ],
      ),
    ),
  );
}


class InProgressTasks extends ConsumerWidget {
  const InProgressTasks({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hardcoded from: http://127.0.0.1:54323/project/default/editor/17698    
    final tasks = ref.watch(tasksListenerDatabaseProvider('a0307617-7384-4885-adfe-dd45c33f9c7b'));

    if (tasks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        /*
        return ListTile(
          title: Text(tasks[index].name), // Assuming TaskModel has a 'name' field
        );
        */
        return taskPreview(tasks[index]);
      },
    );
    }
  
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
