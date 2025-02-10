import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:seren_ai_flutter/services/ai_interaction/widgets/ai_assistant_button.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_overview/project_tasks_section.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_overview/sub_lists/project_tasks_filters.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_overview/sub_lists/project_tasks_list_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_filter_state_provider.dart';

// TODO p3: add sort
// TODO p4: add multi type searching - this should search on notes, shifts, etc. in the future
class TaskSearchModal extends HookConsumerWidget {
  const TaskSearchModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(taskFilterStateProvider);
    final filterNotifier = ref.read(taskFilterStateProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 1,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    autofocus: true,
                    onChanged: filterNotifier.updateSearchQuery,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.search,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                AiAssistantButton(
                  size: 30,
                  onPreClick: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
              ],
            ),
            ProjectTasksFilters(
              viewMode: ProjectTasksSectionViewMode.list,
              onShowCustomDateRangePicker: _showCustomDateRangePicker,
              showExtraViewControls: false,
              useHorizontalScroll: true,
            ),
            Expanded(
              child: ProjectTasksListView(
                filterCondition: filterState.filterCondition,
                // TODO p3: add sort
                //sort: filterState.sortComparator,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTimeRange?> _showCustomDateRangePicker(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 360,
          height: 480,
          child: DateRangePickerDialog(
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            initialEntryMode: DatePickerEntryMode.calendarOnly,
          ),
        ),
      ),
    );
  }
}
