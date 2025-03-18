import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai/widgets/base_ai_assistant_button.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_overview/sub_lists/project_tasks_filters.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_view_type.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/tasks_filtered_list_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_state_provider.dart';

Future<void> showTaskSearchModal(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const TaskSearchModal(),
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.9,
    ),
  );
}

// TODO p3: add sort
// TODO p4: add multi type searching - this should search on notes, shifts, etc. in the future
class TaskSearchModal extends HookConsumerWidget {
  const TaskSearchModal({
    super.key,
    this.onTapOption,
    // this.hiddenFilters,
    this.additionalFilter,
    this.autoFocus = true,
    this.viewType = TaskFilterViewType.taskSearch,
    this.projectId,
  });

  /// If this is null, tapping on a task will open the task page
  final void Function(String taskId)? onTapOption;

  /// Filters to hide from the filter list
  // No longer needed as we're using TaskFilterViewType on the options provider
  // final List<TaskFieldEnum>? hiddenFilters;

  /// Additional filter to apply to the tasks (e.g. only show tasks from a certain phase)
  final bool Function(TaskModel)? additionalFilter;

  /// Whether to auto focus the search field
  final bool autoFocus;

  /// The view type to use for the tasksFilteredProvider.
  ///
  /// Defaults to [TaskFilterViewType.taskSearch].
  final TaskFilterViewType viewType;

  /// The project id to filter the tasks by.
  ///
  /// Use this instead of [additionalFilter] to improve performance. (See [TasksFilteredListView] for clarification)
  final String? projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterNotifier = ref.read(taskFilterStateProvider(viewType).notifier);

    return Padding(
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
              BaseAiAssistantButton(
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
            viewType: viewType,
            // hiddenFilters: hiddenFilters,
          ),
          Expanded(
            child: TasksFilteredListView(
              viewType: viewType,
              additionalFilter: additionalFilter,
              onTapTask: onTapOption,
              projectId: projectId,
            ),
          ),
        ],
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
