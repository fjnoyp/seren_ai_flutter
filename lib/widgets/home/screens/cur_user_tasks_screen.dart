import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/common/recent_updated_items/date_grouped_items.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_user_grouped_tasks_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_list_item_view.dart';

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.group});

  final DateGroupedItems group;

  String _getDateHeader(BuildContext context) {
    if (group.isToday) {
      return AppLocalizations.of(context)?.today ?? 'Today';
    }
    // For overdue tasks (using yesterday's date in the provider)
    if (group.isYesterday) {
      return AppLocalizations.of(context)?.overdue ?? 'Overdue';
    }
    if (group.isLastWeek) {
      return DateFormat.EEEE(AppLocalizations.of(context)?.localeName)
          .format(group.date);
    }
    return DateFormat.yMMMd(AppLocalizations.of(context)?.localeName)
        .format(group.date);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Text(
              _getDateHeader(context),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Divider(
                color: Theme.of(context).colorScheme.primary.withAlpha(128),
                thickness: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _TasksList extends StatelessWidget {
  const _TasksList({required this.tasks});

  final List<TaskModel> tasks;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: tasks.length,
      itemBuilder: (context, index) => TaskListItemView(task: tasks[index]),
      separatorBuilder: (context, index) => Divider(
        color: Theme.of(context).dividerColor.withAlpha(38),
      ),
    );
  }
}

class CurUserTasksScreen extends ConsumerWidget {
  const CurUserTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myTasksAsync = ref.watch(curUserGroupedTasksStreamProvider);

    return myTasksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (groupedTasks) {
        if (groupedTasks.isEmpty) {
          return const Center(child: Text('No tasks assigned to you'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: groupedTasks.length,
          itemBuilder: (context, index) {
            final group = groupedTasks[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DateHeader(group: group),
                _TasksList(tasks: group.items.cast<TaskModel>()),
              ],
            );
          },
        );
      },
    );
  }
}
