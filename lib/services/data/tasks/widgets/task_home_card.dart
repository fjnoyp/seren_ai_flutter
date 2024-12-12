import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_user_viewable_tasks_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/joined_task_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_page.dart';
import 'package:seren_ai_flutter/widgets/home/base_home_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TaskHomeCard extends ConsumerWidget {
  const TaskHomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchedTasks = ref.watch(curUserViewableTasksProvider);

    return BaseHomeCard(
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
                            child: _TaskCardItem(task: task))),
                    Flexible(
                      fit: FlexFit.loose,
                      child: BaseHomeInnerCard.filled(
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.tasks.name);
                          },
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.seeAll,
                              style: Theme.of(context).textTheme.bodySmall,
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

class _TaskCardItem extends ConsumerWidget {
  final TaskModel task;

  const _TaskCardItem({super.key, required this.task});

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
      child: BaseHomeInnerCard.outlined(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              task.name,
              style: Theme.of(context).textTheme.labelSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}