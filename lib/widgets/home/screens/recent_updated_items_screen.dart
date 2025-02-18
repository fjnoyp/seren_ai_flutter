import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/common/recent_updated_items/date_grouped_items.dart';
import 'package:seren_ai_flutter/services/data/common/recent_updated_items/recent_updated_items_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/note_list_item_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_list_item_view.dart';

class RecentUpdatedItemsScreen extends ConsumerWidget {
  const RecentUpdatedItemsScreen({super.key});

  String _getDateHeader(BuildContext context, DateGroupedItems group) {
    if (group.isToday) {
      return AppLocalizations.of(context)?.today ?? 'Today';
    }
    if (group.isYesterday) {
      return 'Yesterday';
    }
    if (group.isLastWeek) {
      return DateFormat.EEEE(AppLocalizations.of(context)?.localeName)
          .format(group.date);
    }
    return DateFormat.yMMMd(AppLocalizations.of(context)?.localeName)
        .format(group.date);
  }

  Widget _buildDateHeader(BuildContext context, DateGroupedItems group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24), // Increased spacing between days
        Row(
          children: [
            Text(
              _getDateHeader(context, group),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Divider(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.5),
                thickness: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildItemsList(BuildContext context, List<dynamic> items) {
    return Column(
      children: items.asMap().entries.map((entry) {
        final item = entry.value;
        final isLast = entry.key == items.length - 1;

        return Column(
          children: [
            if (item is TaskModel)
              TaskListItemView(task: item, showStatus: true, showProject: true)
            else if (item is NoteModel)
              NoteListItemView(item, showStatus: true),
            if (!isLast) // Don't add divider after last item
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Divider(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
                  height: 1,
                ),
              ),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentItemsAsync = ref.watch(recentUpdatedItemsProvider);

    return recentItemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
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
                _buildDateHeader(context, group),
                _buildItemsList(context, group.items),
              ],
            );
          },
        );
      },
    );
  }
}
