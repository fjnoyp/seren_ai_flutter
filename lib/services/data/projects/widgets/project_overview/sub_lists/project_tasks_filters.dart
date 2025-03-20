import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_options_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_view_type.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_filter.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_field_enum.dart';

class ProjectTasksFilters extends ConsumerWidget {
  const ProjectTasksFilters({
    super.key,
    required this.onShowCustomDateRangePicker,
    this.showExtraViewControls = true,
    required this.useHorizontalScroll,
    required this.viewType,
    // this.hiddenFilters,
  });

  final Future<DateTimeRange?> Function(BuildContext)
      onShowCustomDateRangePicker;

  /// Whether to show extra view controls in the UI.
  /// This can include additional filtering options or settings
  /// that enhance the user experience when managing tasks.
  final bool showExtraViewControls;

  final bool useHorizontalScroll;
  // final List<TaskFieldEnum>? hiddenFilters;

  final TaskFilterViewType viewType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(taskFilterStateProvider(viewType));
    final filterNotifier = ref.read(taskFilterStateProvider(viewType).notifier);

    ref.listen(curSelectedProjectIdNotifierProvider, (_, next) {
      // We need to remove the assignees filter everytime a new project is selected
      // to avoid inconsistencies in the UI

      // We should ideally do this only if the user is not in the new selected project
      // but the commented code below not currently working as expected
      // if (filterState.activeFilters
      //         .firstWhere((filter) => filter.field == TaskFieldEnum.assignees)
      //     case TaskFilter activeFilter) {
      //   final activeFilteredAssigneeId = activeFilter.value;

      //   final projectAssigneesIds = ref
      //           .watch(usersInProjectProvider(next.value!.id))
      //           .value
      //           ?.map((user) => user.id)
      //           .toList() ??
      //       [];

      //   if (!projectAssigneesIds.contains(activeFilteredAssigneeId)) {
      filterNotifier.removeFilter(TaskFieldEnum.assignees);
      // }
      // }
    });

    final filterWidgets = [
      ...ref
          .watch(taskFilterOptionsProvider(viewType))
          .entries
          // .where((entry) => !(hiddenFilters?.contains(entry.key) ?? false))
          .map((entry) => _FilterChip(
                field: entry.key,
                options: entry.value,
                filterState: filterState,
                filterNotifier: filterNotifier,
                onShowCustomDateRangePicker: onShowCustomDateRangePicker,
              )),
      _SortChip(
        filterState: filterState,
        filterNotifier: filterNotifier,
      ),
    ];

    return Row(
      children: [
        useHorizontalScroll
            ? Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var i = 0; i < filterWidgets.length; i++) ...[
                        filterWidgets[i],
                        if (i < filterWidgets.length - 1)
                          const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
              )
            : Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: filterWidgets,
                ),
              ),
        if (showExtraViewControls) ...[
          const SizedBox(width: 8),
          const _NewTaskFromCurrentProjectButton(),
        ],
      ],
    );
  }
}

// TODO: refactor to use a single filter anchor for all options + chips for active filters
class _FilterChip extends ConsumerWidget {
  const _FilterChip({
    required this.field,
    required this.options,
    required this.filterState,
    required this.filterNotifier,
    required this.onShowCustomDateRangePicker,
  });

  final TaskFieldEnum field;
  final List<TaskFilter> options;
  final TaskFilterState filterState;
  final TaskFilterStateNotifier filterNotifier;
  final Future<DateTimeRange?> Function(BuildContext)
      onShowCustomDateRangePicker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MenuAnchor(
      builder: (context, controller, child) {
        return FilterChip(
          selected:
              filterState.activeFilters.any((filter) => filter.field == field),
          avatar: const Icon(Icons.filter_list_outlined),
          label:
              filterState.activeFilters.any((filter) => filter.field == field)
                  ? Text(filterState.activeFilters
                      .firstWhere((filter) => filter.field == field)
                      .readableName)
                  : Text(field.toHumanReadable(context)),
          onDeleted:
              filterState.activeFilters.any((filter) => filter.field == field)
                  ? () => filterNotifier.removeFilter(field)
                  : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          showCheckmark: false,
          onSelected: (selected) {
            controller.isOpen ? controller.close() : controller.open();
          },
        );
      },
      menuChildren: options
          .map(
            (option) => MenuItemButton(
              child: Text(option.readableName),
              onPressed: () {
                if (option.value == 'customDateRange') {
                  onShowCustomDateRangePicker(context).then((value) {
                    if (value != null) {
                      filterNotifier.updateFilter(
                        option.copyWith(
                          readableName:
                              '${option.readableName}: ${DateFormat.MMMd().format(value.start)} - ${DateFormat.Md().format(value.end)}',
                        ),
                      );
                    }
                  });
                } else {
                  filterNotifier.updateFilter(option);
                }
              },
            ),
          )
          .toList(),
    );
  }
}

class _SortChip extends ConsumerWidget {
  const _SortChip({
    required this.filterState,
    required this.filterNotifier,
  });

  final TaskFilterState filterState;
  final TaskFilterStateNotifier filterNotifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MenuAnchor(
      builder: (context, controller, child) {
        return FilterChip(
          selected: filterState.sortBy != null,
          avatar: const Icon(Icons.import_export_outlined),
          label: filterState.sortBy != null
              ? Text(filterState.sortBy!.name)
              : Text(AppLocalizations.of(context)!.sortBy),
          onSelected: (_) {
            controller.isOpen ? controller.close() : controller.open();
          },
          onDeleted: filterState.sortBy != null
              ? () => filterNotifier.updateSortOption(null)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          showCheckmark: false,
        );
      },
      menuChildren: TaskFieldEnum.values
          .where((field) => field.comparator != null)
          .map(
            (option) => MenuItemButton(
              child: Text(option.toHumanReadable(context)),
              onPressed: () => filterNotifier.updateSortOption(option),
            ),
          )
          .toList(),
    );
  }
}

class _NewTaskFromCurrentProjectButton extends ConsumerWidget {
  const _NewTaskFromCurrentProjectButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          child: Text(AppLocalizations.of(context)!.task),
          onPressed: () async =>
              await ref.read(taskNavigationServiceProvider).openNewTask(
                    initialProjectId:
                        ref.read(curSelectedProjectIdNotifierProvider),
                  ),
        ),
        MenuItemButton(
          child: Text(AppLocalizations.of(context)!.phase),
          onPressed: () async =>
              await ref.read(taskNavigationServiceProvider).openNewTask(
                    isPhase: true,
                    initialProjectId:
                        ref.read(curSelectedProjectIdNotifierProvider),
                  ),
        ),
      ],
      builder: (context, controller, _) => FilledButton.tonalIcon(
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.addNew),
        onPressed: controller.open,
      ),
    );
  }
}
