import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/app_routes.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editablePageModeEnum.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_user_viewable_tasks_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/joined_task_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_page.dart';
import 'package:seren_ai_flutter/widgets/home/base_home_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TaskCardItem extends ConsumerWidget {
  final TaskModel task;

  const TaskCardItem({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final joinedTask = await ref
            .read(joinedTasksRepositoryProvider)
            .getJoinedTaskById(task.id);
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
    final watchedTasks = ref.watch(curUserViewableTasksProvider);

    return BaseHomeCard(
      color: Theme.of(context).colorScheme.primaryContainer,
      title: AppLocalizations.of(context)!.todaysTasks,
      child: AsyncValueHandlerWidget(
        value: watchedTasks,
        data: (watchedTasks) {
          // TODO p4: show the latest updated task or some other intelligent task selection
          // get the open tasks that are due the soonest
          final openTasks = watchedTasks
              ?.where((task) =>
                  task.status == StatusEnum.inProgress ||
                  task.status == StatusEnum.open)
              .toList();
      
          return openTasks?.isEmpty ?? true
              ? Center(
                  child: Text(AppLocalizations.of(context)!.noTasksDueToday))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // Changed from ListView to Column
                  children: [
                    // Display the name, status,
                    ...openTasks!.getRange(0, min(2, openTasks.length)).map(
                        (task) => Flexible(
                            fit: FlexFit.loose,
                            child: TaskCardItem(task: task))),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoute.tasks.name);
                          },
                          child: Container(
                            width: double.infinity,
                            height: 30, // Set max height to 10
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.primary),
                              borderRadius: BorderRadius.circular(
                                  12), // Increased the border radius for more rounded edges
                            ),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)!.seeAll,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }
}
