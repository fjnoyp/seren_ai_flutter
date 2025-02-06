import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/widgets/ai_assistant_button.dart';
import 'package:seren_ai_flutter/services/data/projects/task_filter_option_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/task_sort_option_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_overview/sub_lists/project_tasks_board_view.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_overview/sub_lists/project_tasks_filters.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_overview/sub_lists/project_tasks_list_view.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_overview/sub_lists/project_tasks_sectioned_list_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

class ProjectTasksSection extends StatelessWidget {
  const ProjectTasksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isLargeScreen = constraints.maxWidth > 800;
      return isLargeScreen
          ? const ProjectTasksSectionWeb('board')
          : const ProjectTasksSectionMobile();
    });
  }
}

class ProjectTasksSectionWeb extends HookConsumerWidget {
  const ProjectTasksSectionWeb(this.initialViewMode, {super.key});

  // TODO p0: turn into an enum and refactor from here
  final String initialViewMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = useState(initialViewMode);
    final sortBy = useState<TaskSortOption?>(null);
    final filterBy = TaskFilterOption.values
        .map((filter) => useState<
            ({
              String value,
              String name,
              bool Function(TaskModel) filter,
            })?>(null))
        .toList();

    // TODO p3: switch to server side filtering once there are too many tasks
    bool filterCondition(TaskModel task) {
      bool result = true;
      for (var filter in filterBy) {
        if (filter.value?.filter != null) {
          result = result && filter.value!.filter(task);
        }
      }
      return result;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: ProjectTasksFilters(
            filterBy: filterBy,
            sortBy: sortBy,
            viewMode: viewMode,
            onShowCustomDateRangePicker: _showCustomDateRangePicker,
            useHorizontalScroll: false,
          ),
        ),
        Expanded(
          child: AnimatedCrossFade(
            firstChild: ProjectTasksSectionedListView(
              sort: sortBy.value?.comparator,
              filterCondition: filterCondition,
            ),
            secondChild: ProjectTasksBoardView(
              sort: sortBy.value?.comparator,
              filterCondition: filterCondition,
            ),
            crossFadeState: viewMode.value == 'list'
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: Durations.medium1,
          ),
        ),
      ],
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

class ProjectTasksSectionMobile extends StatelessWidget {
  const ProjectTasksSectionMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => _showTaskSearchModal(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Icon(Icons.search),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.search),
                  const Spacer(),
                  const AiAssistantButton(size: 30),
                ],
              ),
            ),
          ),
        ),
        const Expanded(
          child: ProjectTasksSectionedListView(),
        ),
      ],
    );
  }

  Future<void> _showTaskSearchModal(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const TaskSearchModal(),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
    );
  }
}

class TaskSearchModal extends HookConsumerWidget {
  const TaskSearchModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = useState('');
    final sortBy = useState<TaskSortOption?>(null);
    final viewMode = useState('list'); // Mobile modal always uses list view
    final filterBy = TaskFilterOption.values
        .map((filter) => useState<
            ({
              String value,
              String name,
              bool Function(TaskModel) filter,
            })?>(null))
        .toList();

    // TODO p3: switch to server side filtering once there are too many tasks
    // TODO p2: add hybrid search on user searchQuery string to improve search ability
    bool filterCondition(TaskModel task) {
      bool result = true;
      // Apply search filter
      if (searchQuery.value.isNotEmpty) {
        result =
            task.name.toLowerCase().contains(searchQuery.value.toLowerCase());
      }
      // Apply other filters
      for (var filter in filterBy) {
        if (filter.value?.filter != null) {
          result = result && filter.value!.filter(task);
        }
      }
      return result;
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
                    autofocus: true,
                    onChanged: (value) => searchQuery.value = value,
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
              filterBy: filterBy,
              sortBy: sortBy,
              viewMode: viewMode,
              onShowCustomDateRangePicker: _showCustomDateRangePicker,
              showExtraViewControls: false,
              useHorizontalScroll: true,
            ),
            Expanded(
              child: ProjectTasksListView(
                filterCondition: filterCondition,
                //sort: sortBy.value?.comparator,
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
