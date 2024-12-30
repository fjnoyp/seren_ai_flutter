import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/selected_project_service_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/task_filter_option_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/task_sort_option_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_user_viewable_tasks_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_list_item_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/tasks_list_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_page.dart';

class WebProjectTasksSection extends HookConsumerWidget {
  const WebProjectTasksSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = useState('board');
    final sortBy = useState<TaskSortOption?>(null);
    final filterBy = TaskFilterOption.values
        .map((filter) => useState<
            ({
              String value,
              String name,
              bool Function(JoinedTaskModel) filter,
            })?>(null))
        .toList();

    bool filterCondition(JoinedTaskModel task) {
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
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    ...TaskFilterOption.values.map(
                      (filter) {
                        final index = TaskFilterOption.values.indexOf(filter);
                        return MenuAnchor(
                          builder: (context, controller, child) {
                            return FilterChip(
                              selected: filterBy[index].value != null,
                              avatar: const Icon(Icons.filter_list_outlined),
                              label: filterBy[index].value != null
                                  ? Text(filterBy[index].value!.name)
                                  : Text(filter.getDisplayName(context)),
                              onDeleted: filterBy[index].value != null
                                  ? () => filterBy[index].value = null
                                  : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              showCheckmark: false,
                              onSelected: (selected) {
                                controller.isOpen
                                    ? controller.close()
                                    : controller.open();
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
                                      showDateRangePicker(
                                              context: context,
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2100))
                                          .then(
                                        (value) {
                                          if (value != null) {
                                            filterBy[index].value = (
                                              value:
                                                  '${filter.name}_${option.value}',
                                              name:
                                                  '${filter.getDisplayName(context)}: ${DateFormat.MMMd().format(value.start)} - ${DateFormat.Md().format(value.end)}',
                                              filter: (task) =>
                                                  option.filter?.call(task) ??
                                                  filter.filterFunction(
                                                      task, value)
                                            );
                                          }
                                        },
                                      );
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
                            controller.isOpen
                                ? controller.close()
                                : controller.open();
                          },
                          onDeleted: sortBy.value != null
                              ? () => sortBy.value = null
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
                              onPressed: () => sortBy.value = option,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              SegmentedButton(
                segments: const [
                  ButtonSegment(
                      value: 'board',
                      icon: Icon(Icons.view_week),
                      label: Text('Board')),
                  ButtonSegment(
                      value: 'list',
                      icon: Icon(Icons.list),
                      label: Text('List')),
                ],
                selected: {viewMode.value},
                onSelectionChanged: (value) => viewMode.value = value.first,
              ),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.add),
                label: Text(AppLocalizations.of(context)!.createNewTask),
                onPressed: () async => await openTaskPage(context, ref,
                    mode: EditablePageMode.create,
                    initialProject: ref
                        .read(selectedProjectServiceProvider)
                        .value!
                        .project),
              ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedCrossFade(
            firstChild: _ProjectTasksListView(
              sort: sortBy.value?.comparator,
              filterCondition: filterCondition,
            ),
            secondChild: _ProjectTasksBoardView(
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
}

class _ProjectTasksBoardView extends ConsumerWidget {
  const _ProjectTasksBoardView({this.sort, this.filterCondition});

  final Comparator<JoinedTaskModel>? sort;
  final bool Function(JoinedTaskModel)? filterCondition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: StatusEnum.values
          .where((status) =>
              status != StatusEnum.cancelled && status != StatusEnum.archived)
          .map(
            (status) => Expanded(
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        status.toHumanReadable(context),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TasksListView(
                          filter: (joinedTask) =>
                              joinedTask.task.parentProjectId ==
                                  ref
                                      .watch(selectedProjectServiceProvider)
                                      .value!
                                      .project
                                      .id &&
                              joinedTask.task.status == status &&
                              (filterCondition == null ||
                                  filterCondition!(joinedTask)),
                          sort: sort,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(20),
                          alignment: Alignment.centerLeft,
                          overlayColor: Colors.transparent,
                        ),
                        onPressed: () async => await openTaskPage(context, ref,
                            mode: EditablePageMode.create,
                            initialProject: ref
                                .read(selectedProjectServiceProvider)
                                .value!
                                .project,
                            initialStatus: status),
                        child: Text(
                          AppLocalizations.of(context)!.createNewTask,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ProjectTasksListView extends ConsumerWidget {
  const _ProjectTasksListView({this.sort, this.filterCondition});

  final Comparator<JoinedTaskModel>? sort;
  final bool Function(JoinedTaskModel)? filterCondition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueHandlerWidget(
      value: ref.watch(joinedCurUserViewableTasksProvider),
      data: (tasks) {
        return SingleChildScrollView(
          child: Column(
            children: StatusEnum.values.map(
              (status) {
                final filteredTasks = tasks
                        ?.where((task) =>
                            task.task.parentProjectId ==
                                ref
                                    .watch(selectedProjectServiceProvider)
                                    .value!
                                    .project
                                    .id &&
                            task.task.status == status &&
                            (filterCondition == null || filterCondition!(task)))
                        .toList() ??
                    [];

                if (sort != null) {
                  filteredTasks.sort(sort);
                }

                return Card(
                  child: ExpansionTile(
                    initiallyExpanded: filteredTasks.isNotEmpty,
                    title: Text(status.toHumanReadable(context)),
                    expandedAlignment: Alignment.centerLeft,
                    shape: const Border(),
                    childrenPadding: const EdgeInsets.only(bottom: 24),
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) =>
                            TaskListTileItemView(filteredTasks[index]),
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        dense: true,
                        onTap: () => openTaskPage(context, ref,
                            mode: EditablePageMode.create,
                            initialProject: ref
                                .read(selectedProjectServiceProvider)
                                .value!
                                .project,
                            initialStatus: status),
                        leading: const SizedBox.shrink(),
                        title: Text(
                          AppLocalizations.of(context)!.createNewTask,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.outline),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ).toList(),
          ),
        );
      },
    );
  }
}
