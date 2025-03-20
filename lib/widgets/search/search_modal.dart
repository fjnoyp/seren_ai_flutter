import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai/widgets/base_ai_assistant_button.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_overview/sub_lists/project_tasks_filters.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_view_type.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/tasks_filtered_list_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_state_provider.dart';

void showSearchModalDialog(BuildContext context, WidgetRef ref) {
  final size = MediaQuery.of(context).size;
  // Get the actual height of BottomAppBar plus the floating action button and some padding
  final bottomSpaceReserved =
      80.0; // Height for bottom app bar with some extra space

  if (!kIsWeb) {
    // Use a custom positioned dialog for mobile devices that preserves the bottom app bar
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            // This invisible touch area allows tapping outside to dismiss
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: Container(color: Colors.transparent),
              ),
            ),
            // The actual search content positioned to avoid bottom app bar
            Positioned(
              top: MediaQuery.of(context).padding.top +
                  10, // Account for status bar + small margin
              left: 12,
              right: 12,
              bottom:
                  bottomSpaceReserved, // Leave space for bottom app bar + FAB
              child: Material(
                elevation: 16,
                borderRadius: BorderRadius.circular(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: const SearchModal(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  } else {
    // Use a dialog for web
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Material(
              elevation: 16,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: size.width * 0.5,
                constraints: BoxConstraints(
                  maxHeight: size.height * 0.8,
                ),
                child: const SearchModal(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// TODO p3: add sort
// TODO p4: add multi type searching - this should search on notes, shifts, etc. in the future
class SearchModal extends HookConsumerWidget {
  const SearchModal({
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

    return Container(
      color: Theme.of(context).cardColor,
      height: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
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
