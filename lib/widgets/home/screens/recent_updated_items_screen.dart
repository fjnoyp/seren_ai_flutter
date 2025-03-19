import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/ai/ai_context_helper/widgets/ai_context_view.dart';
import 'package:seren_ai_flutter/services/data/common/recent_updated_items/date_grouped_items.dart';
import 'package:seren_ai_flutter/services/data/common/recent_updated_items/recent_updated_items_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/note_list_item_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_list_card_item_view.dart';

class RecentUpdatedItemsScreen extends ConsumerWidget {
  const RecentUpdatedItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueHandlerWidget(
      value: ref.watch(recentUpdatedItemsProvider),
      data: (groupedItems) {
        if (groupedItems.isEmpty) {
          return const Center(child: Text('No recent items'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: groupedItems.length,
          itemBuilder: (context, index) {
            final group = groupedItems[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DateHeader(group),
                _ItemsList(group.items),
              ],
            );
          },
        );
      },
    );
  }
}

class _DateHeader extends ConsumerWidget {
  const _DateHeader(this.group);

  final DateGroupedItems group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24), // Increased spacing between days
        Row(
          children: [
            Text(
              group.getDateHeader(context),
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

class _ItemsList extends StatelessWidget {
  const _ItemsList(this.items);

  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
         // Only show AI context if there are tasks
        if (items.whereType<TaskModel>().isNotEmpty)
          AIContextTaskList(tasks: items.whereType<TaskModel>().toList()),

        // Show the list of items
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];

            return switch (item) {
              TaskModel() => TaskListCardItemView(
                  task: item, showStatus: true, showProject: true),
              NoteModel() => NoteListItemView(item, showStatus: true),
              _ => const SizedBox.shrink(),
            };
          },
          separatorBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Divider(
                color: Theme.of(context).dividerColor.withAlpha(38),
                height: 1,
              ),
            );
          },
        ),
      ],
    );
  }
}
