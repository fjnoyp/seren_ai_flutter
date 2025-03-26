import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filters_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_view_type.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/tasks_filtered_search_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_list_card_item_view.dart';

// Provider to track modal state
final isSearchModalOpenProvider = StateProvider<bool>((ref) => false);

// Function to toggle search modal visibility
void toggleSearchModal(WidgetRef ref) {
  ref.read(isSearchModalOpenProvider.notifier).update((state) => !state);

  // Clear search query when closing
  if (!ref.read(isSearchModalOpenProvider)) {
    ref
        .read(taskSearchQueryProvider(TaskFilterViewType.modalSearch).notifier)
        .state = '';
  }
}

class SearchModal extends ConsumerWidget {
  const SearchModal({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    const bottomSpaceReserved =
        95.0; // Height for bottom app bar with some extra space

    final isSearchModalOpen = ref.watch(isSearchModalOpenProvider);

    return Visibility(
      visible: isSearchModalOpen,
      child: Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: kIsWeb
            ? size.width * 0.25
            : 12, // Center on web, edge margins on mobile
        right: kIsWeb ? size.width * 0.25 : 12,
        bottom: bottomSpaceReserved,
        child: Material(
          elevation: 16,
          borderRadius: BorderRadius.circular(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SearchView(
                  onClose: () {
                    ref.read(isSearchModalOpenProvider.notifier).state = false;
                    ref
                        .read(taskSearchQueryProvider(
                                TaskFilterViewType.modalSearch)
                            .notifier)
                        .state = '';
                  },
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Material(
                    elevation: 4,
                    shape: const CircleBorder(),
                    color: Theme.of(context).colorScheme.primary,
                    child: InkWell(
                      onTap: () {
                        toggleSearchModal(ref);
                      },
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// TODO p3: add sort
// TODO p4: add multi type searching - this should search on notes, shifts, etc. in the future
class SearchView extends HookConsumerWidget {
  const SearchView({
    super.key,
    this.onTapOption,
    this.additionalFilter,
    this.autoFocus = true,
    this.onClose,
    this.emptyStateWidget,
    this.itemBuilder,
    this.separatorBuilder,
  });

  /// If this is null, tapping on a task will open the task page
  final void Function(String taskId)? onTapOption;

  /// Additional filter to apply to the tasks (e.g. only show tasks from a certain phase)
  final bool Function(TaskModel)? additionalFilter;

  /// Whether to auto focus the search field
  final bool autoFocus;

  /// The view type to use for filtering
  final TaskFilterViewType viewType = TaskFilterViewType.modalSearch;

  /// Callback when the modal is closed
  final VoidCallback? onClose;

  /// Widget to show when no tasks match the filters
  final Widget? emptyStateWidget;

  /// Builder function to create the task item widget
  final Widget Function(TaskModel task, void Function(String taskId)? onTap)?
      itemBuilder;

  /// Builder function to create the separator between items
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the filtered tasks
    final filteredTasksAsync = ref.watch(tasksFilteredSearchProvider(viewType));

    // Create a wrapper for onTapTask that will also close the modal
    final wrappedOnTapTask = onTapOption == null
        ? (String taskId) {
            ref
                .read(taskNavigationServiceProvider)
                .openTask(initialTaskId: taskId);
            onClose?.call();
          }
        : (String taskId) {
            // First call the original callback
            onTapOption!(taskId);

            // Then close the modal
            onClose?.call();
          };

    final searchQuery = ref.watch(taskSearchQueryProvider(viewType));
    final searchController = useTextEditingController(text: searchQuery);

    useEffect(() {
      // Update the controller text when the search query changes externally
      if (searchQuery != searchController.text) {
        searchController.text = searchQuery;
      }

      return null;
    }, [searchQuery]);

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
                    controller: searchController,
                    autofocus: autoFocus,
                    onChanged: (value) {
                      // Update both filter state and our local search query
                      ref
                          .read(taskSearchQueryProvider(viewType).notifier)
                          .state = value;
                    },
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.search,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            TaskFiltersView(
              showExtraViewControls: false,
              useHorizontalScroll: true,
              viewType: viewType,
            ),
            Expanded(
              child: AsyncValueHandlerWidget(
                value: filteredTasksAsync,
                data: (tasks) {
                  // Apply additional filter if provided
                  final filteredTasks = additionalFilter != null
                      ? tasks.where(additionalFilter!).toList()
                      : tasks;

                  return _TaskList(
                    tasks: filteredTasks,
                    onTapTask: wrappedOnTapTask,
                    emptyStateWidget: emptyStateWidget,
                    itemBuilder: itemBuilder,
                    separatorBuilder: separatorBuilder,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskList extends ConsumerWidget {
  const _TaskList({
    required this.tasks,
    required this.onTapTask,
    this.emptyStateWidget,
    this.itemBuilder,
    this.separatorBuilder,
  });

  final List<TaskModel> tasks;
  final void Function(String taskId) onTapTask;
  final Widget? emptyStateWidget;
  final Widget Function(TaskModel task, void Function(String taskId)? onTap)?
      itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show empty state if no tasks match the filter
    if (tasks.isEmpty) {
      return emptyStateWidget ??
          Center(
            child: Text(
              AppLocalizations.of(context)?.noTasksFound ?? 'No tasks found',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
    }

    // Display the tasks
    return ListView.separated(
      shrinkWrap: true,
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return itemBuilder != null
            ? itemBuilder!(task, onTapTask)
            : TaskListCardItemView(
                task: task,
                onTap: onTapTask,
                showStatus: false,
                showProject: false,
                showAssignees: false,
                showMoreOptionsButton: false,
                showDescription: false,
              );
      },
      separatorBuilder:
          separatorBuilder ?? (context, index) => const Divider(height: 1),
    );
  }
}
