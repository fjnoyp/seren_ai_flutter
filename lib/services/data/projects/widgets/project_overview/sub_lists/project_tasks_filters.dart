import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/projects/task_filter_option_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/task_sort_option_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_overview/project_tasks_section.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_filter_state_provider.dart';

class ProjectTasksFilters extends ConsumerWidget {
  const ProjectTasksFilters({
    super.key,
    required this.viewMode,
    required this.onShowCustomDateRangePicker,

    /// Whether to show extra view controls in the UI.
    /// This can include additional filtering options or settings
    /// that enhance the user experience when managing tasks.
    this.showExtraViewControls = true,
    required this.useHorizontalScroll,
  });

  final ProjectTasksSectionViewMode viewMode;
  final Future<DateTimeRange?> Function(BuildContext)
      onShowCustomDateRangePicker;
  final bool showExtraViewControls;
  final bool useHorizontalScroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(taskFilterStateProvider);
    final filterNotifier = ref.read(taskFilterStateProvider.notifier);

    final filterWidgets = [
      ...TaskFilterOption.values.map(
        (filter) => _FilterChip(
          filter: filter,
          filterState: filterState,
          filterNotifier: filterNotifier,
          onShowCustomDateRangePicker: onShowCustomDateRangePicker,
        ),
      ),
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

class _FilterChip extends ConsumerWidget {
  const _FilterChip({
    required this.filter,
    required this.filterState,
    required this.filterNotifier,
    required this.onShowCustomDateRangePicker,
  });

  final TaskFilterOption filter;
  final TaskFilterState filterState;
  final TaskFilterStateNotifier filterNotifier;
  final Future<DateTimeRange?> Function(BuildContext)
      onShowCustomDateRangePicker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = TaskFilterOption.values.indexOf(filter);
    return MenuAnchor(
      builder: (context, controller, child) {
        return FilterChip(
          selected: filterState.activeFilters[index] != null,
          avatar: const Icon(Icons.filter_list_outlined),
          label: filterState.activeFilters[index] != null
              ? Text(filterState.activeFilters[index]!.name!)
              : Text(filter.getDisplayName(context)),
          onDeleted: filterState.activeFilters[index] != null
              ? () => filterNotifier.updateFilter(index, null)
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
      menuChildren: filter
          .getSubOptions(context, ref)
          .map(
            (option) => MenuItemButton(
              child: Text(option.name),
              onPressed: () {
                if (option.value == 'customDateRange') {
                  onShowCustomDateRangePicker(context).then((value) {
                    if (value != null) {
                      filterNotifier.updateFilter(index, (
                        value: '${filter.name}_${option.value}',
                        name:
                            '${filter.getDisplayName(context)}: ${DateFormat.MMMd().format(value.start)} - ${DateFormat.Md().format(value.end)}',
                        filter: (task) =>
                            option.filter?.call(task) ??
                            filter.filterFunction(task, value)
                      ));
                    }
                  });
                } else {
                  filterNotifier.updateFilter(index, (
                    value: '${filter.name}_${option.value}',
                    name: '${filter.getDisplayName(context)}: ${option.name}',
                    filter: (task) =>
                        option.filter?.call(task) ??
                        filter.filterFunction(task, null)
                  ));
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
      menuChildren: TaskSortOption.values
          .map(
            (option) => MenuItemButton(
              child: Text(option.name),
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
