import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/widgets/ai_assistant_button.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_overview/sub_lists/project_tasks_filters.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_filter_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/tasks_by_project_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_field_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/tasks_list_tiles_view.dart';

// TODO p3: add sort
// TODO p4: add multi type searching - this should search on notes, shifts, etc. in the future
class TaskSearchModal extends HookConsumerWidget {
  const TaskSearchModal({
    super.key,
    this.onTapOption,
    this.hiddenFilters,
    this.additionalFilter,
    this.autoFocus = true,
  });

  /// If this is null, tapping on a task will open the task page
  final void Function(String taskId)? onTapOption;

  /// Filters to hide from the filter list
  final List<TaskFieldEnum>? hiddenFilters;

  /// Additional filter to apply to the tasks (e.g. only show tasks from a certain phase)
  final bool Function(TaskModel)? additionalFilter;

  /// Whether to auto focus the search field
  final bool autoFocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(taskFilterStateProvider);
    final filterNotifier = ref.read(taskFilterStateProvider.notifier);

    // TODO p0: project selection needs to be a filter ... and NOT be hardcoded
    final projectId = ref.watch(curSelectedProjectIdNotifierProvider);
    if (projectId == null) {
      return const SizedBox.shrink();
    }

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
                    autofocus: autoFocus,
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
              onShowCustomDateRangePicker: _showCustomDateRangePicker,
              showExtraViewControls: false,
              useHorizontalScroll: true,
              hiddenFilters: hiddenFilters,
            ),
            Expanded(
              child: TasksListTilesView(
                watchedTasks: ref
                    .watch(tasksByProjectStreamProvider(projectId))
                    .whenData((tasks) => additionalFilter != null
                        ? tasks?.where(additionalFilter!).toList()
                        : tasks),
                filterCondition: (task) => filterState.filterCondition(task),
                // TODO p3: add sort
                //sort: filterState.sortComparator,
                onTapOption: onTapOption,
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
