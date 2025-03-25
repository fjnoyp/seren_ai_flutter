import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/recent_updated_items/date_grouped_items.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/select_project_widget.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_user_viewable_projects_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_user_grouped_tasks_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_list_card_item_view.dart';

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.group});

  final DateGroupedItems group;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Text(
              group.getDateHeader(context),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Divider(
                color: Theme.of(context).colorScheme.primary.withAlpha(128),
                thickness: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _TasksList extends StatelessWidget {
  const _TasksList({required this.tasks});

  final List<TaskModel> tasks;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) => TaskListCardItemView(task: tasks[index]),
      separatorBuilder: (context, index) => Divider(
        color: Theme.of(context).dividerColor.withAlpha(38),
      ),
    );
  }
}

class CurUserTasksScreen extends HookConsumerWidget {
  const CurUserTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curUser = ref.watch(curUserProvider).value;
    final curProjectId = useState<String?>(null);
    // Add state to track if "All" is selected
    final showAllTasks = useState<bool>(false);

    // Watch viewable projects to handle default project selection
    final viewableProjects = ref.watch(curUserViewableProjectsProvider);

    // Effect to handle default project selection
    useEffect(() {
      if (viewableProjects.hasValue) {
        final projects = viewableProjects.value!;
        final defaultProjectId = curUser?.defaultProjectId;

        // If default project exists and is in viewable projects, select it
        if (defaultProjectId != null &&
            projects.any((p) => p.id == defaultProjectId)) {
          curProjectId.value = defaultProjectId;
          showAllTasks.value = false;
        } else {
          // Fallback to all tasks if default not found
          curProjectId.value = null;
          showAllTasks.value = true;
        }
      }
      return null;
    }, [viewableProjects, curUser]);

    return Column(
      children: [
        const SizedBox(height: 16),
        SelectProjectWidget(
          curProjectIdValueNotifier: curProjectId,
          showAllValueNotifier: showAllTasks,
          showPersonalOption: false,
        ),
        Expanded(
          child: _CurUserTasksList(
              // Use null to show all tasks since we don't have personal tasks
              projectId: showAllTasks.value ? null : curProjectId.value),
        ),
      ],
    );
  }
}

class _CurUserTasksList extends ConsumerWidget {
  const _CurUserTasksList({this.projectId});

  final String? projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myTasksAsync = projectId == null
        ? ref.watch(curUserGroupedTasksStreamProvider)
        : ref.watch(curUserGroupedTasksByProjectStreamProvider(projectId!));

    return AsyncValueHandlerWidget(
      value: myTasksAsync,
      data: (groupedTasks) {
        if (groupedTasks.isEmpty) {
          return Center(
              child: Text(AppLocalizations.of(context)?.noTasksAssignedToYou ??
                  'No tasks assigned to you'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: groupedTasks.length,
          itemBuilder: (context, index) {
            final group = groupedTasks[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DateHeader(group: group),
                _TasksList(tasks: group.items.cast<TaskModel>()),
              ],
            );
          },
        );
      },
    );
  }
}
