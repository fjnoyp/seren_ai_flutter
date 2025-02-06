import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/projects/task_filter_option_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/task_sort_option_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_overview/project_tasks_section.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';

class ProjectTasksFilters extends ConsumerWidget {
  const ProjectTasksFilters({
    super.key,
    required this.filterBy,
    required this.sortBy,
    required this.viewMode,
    required this.onShowCustomDateRangePicker,

    /// Whether to show extra view controls in the UI.
    /// This can include additional filtering options or settings
    /// that enhance the user experience when managing tasks.
    this.showExtraViewControls = true,
    required this.useHorizontalScroll,
  });

  final List<
      ValueNotifier<
          ({
            String? value,
            String? name,
            bool Function(TaskModel)? filter,
          })?>> filterBy;
  final ValueNotifier<TaskSortOption?> sortBy;
  final ProjectTasksSectionViewMode viewMode;
  final Future<DateTimeRange?> Function(BuildContext)
      onShowCustomDateRangePicker;
  final bool showExtraViewControls;
  final bool useHorizontalScroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterWidgets = [
      ...TaskFilterOption.values.map(
        (filter) {
          final index = TaskFilterOption.values.indexOf(filter);
          return MenuAnchor(
            builder: (context, controller, child) {
              return FilterChip(
                selected: filterBy[index].value != null,
                avatar: const Icon(Icons.filter_list_outlined),
                label: filterBy[index].value != null
                    ? Text(filterBy[index].value!.name!)
                    : Text(filter.getDisplayName(context)),
                onDeleted: filterBy[index].value != null
                    ? () => filterBy[index].value = null
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
                            filterBy[index].value = (
                              value: '${filter.name}_${option.value}',
                              name:
                                  '${filter.getDisplayName(context)}: ${DateFormat.MMMd().format(value.start)} - ${DateFormat.Md().format(value.end)}',
                              filter: (task) =>
                                  option.filter?.call(task) ??
                                  filter.filterFunction(task, value)
                            );
                          }
                        });
                      } else {
                        filterBy[index].value = (
                          value: '${filter.name}_${option.value}',
                          name:
                              '${filter.getDisplayName(context)}: ${option.name}',
                          filter: (task) =>
                              option.filter?.call(task) ??
                              filter.filterFunction(task, null)
                        );
                      }
                    },
                  ),
                )
                .toList(),
            child: Text(filter.name),
          );
        },
      ),
      MenuAnchor(
        builder: (context, controller, child) {
          return FilterChip(
            selected: sortBy.value != null,
            avatar: const Icon(Icons.import_export_outlined),
            label: sortBy.value != null
                ? Text(sortBy.value!.name)
                : Text(AppLocalizations.of(context)!.sortBy),
            onSelected: (_) {
              controller.isOpen ? controller.close() : controller.open();
            },
            onDeleted: sortBy.value != null ? () => sortBy.value = null : null,
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
                onPressed: () => sortBy.value = option,
              ),
            )
            .toList(),
      ),
    ];

    return Row(
      children: [
        useHorizontalScroll
            ? SingleChildScrollView(
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
              )
            : Wrap(
                spacing: 8,
                runSpacing: 4,
                children: filterWidgets,
              ),
        if (showExtraViewControls) ...[
          const Expanded(child: SizedBox()),
          const NewTaskFromCurrentProjectButton(),
        ],
      ],
    );
  }
}

class NewTaskFromCurrentProjectButton extends ConsumerWidget {
  const NewTaskFromCurrentProjectButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton.tonalIcon(
      icon: const Icon(Icons.add),
      label: Text(AppLocalizations.of(context)!.createNewTask),
      onPressed: () async => await ref
          .read(taskNavigationServiceProvider)
          .openNewTask(
            initialProjectId: ref.read(curSelectedProjectIdNotifierProvider),
          ),
    );
  }
}
