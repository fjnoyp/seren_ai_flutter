import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_project_state_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/task_filter_option_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/task_sort_option_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_user_viewable_tasks_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_list_item_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/tasks_list_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_page.dart';
import 'package:seren_ai_flutter/widgets/home/base_home_card.dart';

class WebProjectTasksSection extends HookConsumerWidget {
  const WebProjectTasksSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = useState('board');
    final sortBy = useState<TaskSortOption?>(null);
    final filterBy = useState<
        ({
          String value,
          String name,
          bool Function(JoinedTaskModel) filter,
        })?>(null);

    var colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              MenuAnchor(
                builder: (context, controller, child) {
                  return OutlinedButton.icon(
                    icon: const Icon(Icons.filter_list_outlined),
                    label: filterBy.value != null
                        ? Text(filterBy.value!.name)
                        : Text(AppLocalizations.of(context)!.filterBy),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          filterBy.value != null ? null : colorScheme.onSurface,
                      side: BorderSide(
                        color: filterBy.value != null
                            ? colorScheme.primary
                            : colorScheme.outline,
                      ),
                    ),
                    onPressed: () {
                      controller.isOpen
                          ? controller.close()
                          : controller.open();
                    },
                  );
                },
                menuChildren: TaskFilterOption.values
                    .map(
                      (option) => SubmenuButton(
                        menuChildren: option
                            .getSubOptions(context, ref)
                            .map(
                              (subOption) => MenuItemButton(
                                child: Text(subOption.name),
                                onPressed: () {
                                  if (subOption.value == 'customDateRange') {
                                    showDateRangePicker(
                                            context: context,
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100))
                                        .then(
                                      (value) {
                                        if (value != null) {
                                          filterBy.value = (
                                            value:
                                                '${option.name}_${subOption.value}',
                                            name:
                                                '${option.getDisplayName(context)}: ${DateFormat.MMMd().format(value.start)} - ${DateFormat.Md().format(value.end)}',
                                            filter: (task) =>
                                                subOption.filter?.call(task) ??
                                                option.filterFunction(
                                                    task, value)
                                          );
                                        }
                                      },
                                    );
                                  } else {
                                    filterBy.value = (
                                      value:
                                          '${option.name}_${subOption.value}',
                                      name:
                                          '${option.getDisplayName(context)}: ${subOption.name}',
                                      filter: (task) =>
                                          subOption.filter?.call(task) ??
                                          option.filterFunction(task, null)
                                    );
                                  }
                                },
                              ),
                            )
                            .toList(),
                        child: Text(option.name),
                      ),
                    )
                    .toList(),
              ),
              if (filterBy.value != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => filterBy.value = null,
                ),
              const SizedBox(width: 8),
              MenuAnchor(
                builder: (context, controller, child) {
                  return OutlinedButton.icon(
                    icon: const Icon(Icons.import_export_outlined),
                    label: sortBy.value != null
                        ? Text(sortBy.value!.name)
                        : Text(AppLocalizations.of(context)!.sortBy),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          sortBy.value != null ? null : colorScheme.onSurface,
                      side: BorderSide(
                        color: sortBy.value != null
                            ? colorScheme.primary
                            : colorScheme.outline,
                      ),
                    ),
                    onPressed: () {
                      controller.isOpen
                          ? controller.close()
                          : controller.open();
                    },
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
              if (sortBy.value != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => sortBy.value = null,
                ),
              const Expanded(child: SizedBox.shrink()),
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
              // Switch(
              //   value: isListView.value,
              //   onChanged: (value) => isListView.value = value,
              //   thumbIcon: WidgetStatePropertyAll(
              //     Icon(
              //       isListView.value ? Icons.view_headline : Icons.view_week,
              //       color: colorScheme.surface,
              //     ),
              //   ),
              //   trackColor:
              //       WidgetStatePropertyAll(colorScheme.surfaceContainerHighest),
              //   trackOutlineColor: WidgetStatePropertyAll(colorScheme.outline),
              //   thumbColor: WidgetStatePropertyAll(colorScheme.secondary),
              // ),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.add),
                label: Text(AppLocalizations.of(context)!.createNewTask),
                onPressed: () async => await openTaskPage(context, ref,
                    mode: EditablePageMode.create,
                    initialProject: ref.read(curProjectStateProvider).project),
              ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedCrossFade(
            firstChild: _ProjectTasksListView(
              sort: sortBy.value?.comparator,
              filterCondition: filterBy.value?.filter,
            ),
            secondChild: _ProjectTasksBoardView(
              sort: sortBy.value?.comparator,
              filterCondition: filterBy.value?.filter,
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: StatusEnum.values
            .map(
              (status) => SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
                child: BaseHomeInnerCard.outlined(
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
                                        .watch(curProjectStateProvider)
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
                          onPressed: () async => await openTaskPage(
                              context, ref,
                              mode: EditablePageMode.create,
                              initialProject:
                                  ref.read(curProjectStateProvider).project,
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
      ),
    );
  }
}

class _ProjectTasksListView extends ConsumerWidget {
  const _ProjectTasksListView({this.sort, this.filterCondition});

  final Comparator<JoinedTaskModel>? sort;
  final bool Function(JoinedTaskModel)? filterCondition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: StatusEnum.values
            .map(
              (status) => ExpansionTile(
                initiallyExpanded: true,
                title: Text(status.toHumanReadable(context)),
                expandedAlignment: Alignment.centerLeft,
                shape: const Border(),
                childrenPadding: const EdgeInsets.only(bottom: 24),
                children: [
                  AsyncValueHandlerWidget(
                    value: ref.watch(joinedCurUserViewableTasksProvider),
                    data: (tasks) {
                      final filteredTasks = tasks
                              ?.where((task) =>
                                  task.task.parentProjectId ==
                                      ref
                                          .watch(curProjectStateProvider)
                                          .project
                                          .id &&
                                  task.task.status == status &&
                                  (filterCondition == null ||
                                      filterCondition!(task)))
                              .toList() ??
                          [];

                      if (sort != null) {
                        filteredTasks.sort(sort);
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) =>
                            TaskListTileItemView(filteredTasks[index]),
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                      );
                    },
                  ),
                  ListTile(
                    dense: true,
                    onTap: () => openTaskPage(context, ref,
                        mode: EditablePageMode.create,
                        initialProject:
                            ref.read(curProjectStateProvider).project,
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
            )
            .toList(),
      ),
    );
  }
}
