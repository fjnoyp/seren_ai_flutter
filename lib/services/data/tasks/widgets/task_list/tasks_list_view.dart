import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/tasks/cur_tasks/joined_cur_user_tasks_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_list_item_view.dart';

class TasksListView extends ConsumerWidget {
  final DateFormat listDateFormat = DateFormat('MMM dd');

  TasksListView({Key? key, required this.filter}) : super(key: key);

  final bool Function(JoinedTaskModel) filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // TODO p2: we can split providers instead ... 
    final filteredTasks = ref.watch(joinedCurUserTasksListenerProvider
        .select((joinedTasks) => joinedTasks?.where(filter).toList() ?? []));

    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        return TaskListItemView(joinedTask: filteredTasks[index]);
      },
    );
  }
}
