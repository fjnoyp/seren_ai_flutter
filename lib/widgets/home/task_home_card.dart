import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editablePageModeEnum.dart';
import 'package:seren_ai_flutter/services/data/tasks/cur_tasks/cur_user_viewable_tasks_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/cur_tasks/joined_cur_user_tasks_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_status_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_page.dart';
import 'package:seren_ai_flutter/widgets/home/base_home_card.dart';

class TaskCardItem extends ConsumerWidget {
  final TaskModel task;

  const TaskCardItem({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final joinedTask = await ref.read(joinedCurUserTasksListenerProvider.notifier).getJoinedTask(task);
        await openTaskPage(context, ref,
              mode: EditablePageMode.readOnly, initialJoinedTask: joinedTask);
        
      },
      child: Card(
        color: Theme.of(context).colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                task.name,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskHomeCard extends ConsumerWidget {
  const TaskHomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO p4: show the latest updated task or some other intelligent task selection 
    final watchedTasks = ref.watch(curUserViewableTasksListenerProvider);

    // get the open tasks that are due the soonest
    final openTasks = watchedTasks
        ?.where((task) =>
            task.status == StatusEnum.inProgress ||
            task.status == StatusEnum.open)
        .toList();

    final firstTask = openTasks?.first;
    final secondTask = openTasks?[1];

    return BaseHomeCard(
      color: Theme.of(context).colorScheme.primaryContainer,
      title: "Today's Tasks",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            fit:
                FlexFit.tight, // Ensures the child takes up the available space
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // Changed from ListView to Column
              children: [
                // Display the name, status,
                firstTask != null
                    ? Flexible(
                        fit: FlexFit.tight,
                        child: TaskCardItem(task: firstTask))
                    : Container(),
                secondTask != null
                    ? Flexible(
                        fit: FlexFit.loose,
                        child: TaskCardItem(task: secondTask))
                    : Container(),
                Flexible(
                  fit: FlexFit.loose,
                  child: Card(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        height: 30, // Set max height to 10
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.primary),
                          borderRadius: BorderRadius.circular(
                              12), // Increased the border radius for more rounded edges
                        ),
                        child: Center(
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, tasksRoute);
                            },
                            child: Text(
                              "See All",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
