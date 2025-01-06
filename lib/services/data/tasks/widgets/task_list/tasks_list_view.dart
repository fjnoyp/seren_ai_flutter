import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_user_viewable_tasks_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_list_item_view.dart';

class TasksListView extends ConsumerWidget {
  const TasksListView({super.key, required this.filter, this.sort});

  final bool Function(TaskModel) filter;
  final Comparator<TaskModel>? sort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueHandlerWidget(
      value: ref.watch(curUserViewableTasksProvider),
      data: (tasks) {
        // TODO p2: we can split providers instead ...
        final filteredTasks = tasks?.where(filter).toList();

        if (filteredTasks == null) {
          return const Center(child: Text('No tasks found'));
        }

        if (sort != null) {
          filteredTasks.sort(sort);
        }

        return ListView.builder(
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            return TaskListItemView(task: filteredTasks[index]);
          },
        );
      },
    );
  }
}
