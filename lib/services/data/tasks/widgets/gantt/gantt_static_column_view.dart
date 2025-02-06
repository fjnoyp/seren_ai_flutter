import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_field_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/experimental/viewable_tasks_hierarchy_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_priority_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_status_view.dart';
import 'package:seren_ai_flutter/services/data/users/providers/task_assigned_users_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/users/widgets/user_avatar.dart';

class GanttStaticColumnView extends ConsumerWidget {
  static const Map<TaskFieldEnum, double> columnWidths = {
    TaskFieldEnum.name: 110.0,
    TaskFieldEnum.status: 80.0,
    TaskFieldEnum.priority: 80.0,
    TaskFieldEnum.assignees: 80.0,
  };

  final ScrollController? verticalController;
  final double cellHeight;
  final ScrollController mainVerticalController;

  const GanttStaticColumnView({
    super.key,
    required this.cellHeight,
    this.verticalController,
    required this.mainVerticalController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleTaskIds = ref.watch(curUserViewableTasksHierarchyIdsProvider);
    final staticColumnHeaders = [
      TaskFieldEnum.name,
      TaskFieldEnum.assignees,
      TaskFieldEnum.status,
      TaskFieldEnum.priority
    ];

    return Listener(
      onPointerSignal: _handlePointerScroll,
      child: GestureDetector(
        onVerticalDragUpdate: _handleVerticalDrag,
        child: SizedBox(
          width: staticColumnHeaders.fold<double>(
            0,
            (sum, field) => sum + columnWidths[field]!,
          ),
          child: Column(
            children: [
              _StaticHeader(
                staticColumnHeaders: staticColumnHeaders,
              ),
              _StaticRowValues(
                taskIds: visibleTaskIds,
                cellHeight: cellHeight,
                verticalController: verticalController,
                staticColumnHeaders: staticColumnHeaders,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePointerScroll(PointerSignalEvent pointerSignal) {
    if (pointerSignal is PointerScrollEvent) {
      mainVerticalController.position.moveTo(
        mainVerticalController.offset + pointerSignal.scrollDelta.dy,
        clamp: true,
      );
    }
  }

  void _handleVerticalDrag(DragUpdateDetails details) {
    mainVerticalController.position.moveTo(
      mainVerticalController.offset - details.delta.dy,
      clamp: true,
    );
  }
}

class _StaticHeader extends StatelessWidget {
  final List<TaskFieldEnum> staticColumnHeaders;

  const _StaticHeader({required this.staticColumnHeaders});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        staticColumnHeaders.length,
        (index) => Container(
          width:
              GanttStaticColumnView.columnWidths[staticColumnHeaders[index]]!,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant),
            ),
          ),
          child: Text(
            staticColumnHeaders[index].toHumanReadable(context),
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _StaticRowValues extends StatelessWidget {
  final List<String> taskIds;
  final double cellHeight;
  final ScrollController? verticalController;
  final List<TaskFieldEnum> staticColumnHeaders;

  const _StaticRowValues({
    required this.taskIds,
    required this.cellHeight,
    required this.verticalController,
    required this.staticColumnHeaders,
  });

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary should wrap the ListView, not the Expanded
    return Expanded(
      child: RepaintBoundary(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView.separated(
            physics: const ClampingScrollPhysics(),
            controller: verticalController,
            itemCount: taskIds.length,
            cacheExtent: 200,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            itemBuilder: (context, rowIndex) => _StaticRow(
              taskId: taskIds[rowIndex],
              cellHeight: cellHeight,
              staticColumnHeaders: staticColumnHeaders,
            ),
            separatorBuilder: (context, index) => const Divider(height: 1),
          ),
        ),
      ),
    );
  }
}

// Split into separate widgets for better performance
class _StaticRow extends ConsumerWidget {
  final String taskId;
  final double cellHeight;
  final List<TaskFieldEnum> staticColumnHeaders;

  const _StaticRow({
    required this.taskId,
    required this.cellHeight,
    required this.staticColumnHeaders,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(taskByIdStreamProvider(taskId));

    return task.when(
      data: (task) => RepaintBoundary(
        child: Row(
          children: List.generate(
            staticColumnHeaders.length,
            (columnIndex) => _StaticCell(
              taskId: taskId,
              cellHeight: cellHeight,
              fieldType: staticColumnHeaders[columnIndex],
            ),
          ),
        ),
      ),
      loading: () => SizedBox(
        height: cellHeight,
        child: const Center(child: LinearProgressIndicator()),
      ),
      error: (error, stackTrace) =>
          const Center(child: Text('Error loading task')),
    );
  }
}

class _StaticCell extends StatelessWidget {
  final String taskId;
  final double cellHeight;
  final TaskFieldEnum fieldType;

  const _StaticCell({
    required this.taskId,
    required this.cellHeight,
    required this.fieldType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      width: GanttStaticColumnView.columnWidths[fieldType]!,
      height: cellHeight - 1, // 1 px taken by the divider
      alignment: Alignment.centerLeft,
      child: _StaticCellContent(
        taskId: taskId,
        fieldType: fieldType,
      ),
    );
  }
}

class _StaticCellContent extends ConsumerWidget {
  final String taskId;
  final TaskFieldEnum fieldType;

  const _StaticCellContent({
    required this.taskId,
    required this.fieldType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(taskByIdStreamProvider(taskId)).value;
    switch (fieldType) {
      case TaskFieldEnum.name:
        return Text(task?.name ?? '', overflow: TextOverflow.ellipsis);
      case TaskFieldEnum.status:
        return Center(
          child: TaskStatusView(
            status: task?.status ?? StatusEnum.open,
            outline: false,
          ),
        );
      case TaskFieldEnum.priority:
        return Center(
          child: TaskPriorityView(
            priority: task?.priority ?? PriorityEnum.normal,
            outline: false,
          ),
        );
      case TaskFieldEnum.assignees:
        return TaskAssigneesAvatars(taskId);
    }
  }
}

class TaskAssigneesAvatars extends ConsumerWidget {
  final String taskId;

  const TaskAssigneesAvatars(this.taskId, {super.key});

  static const avatarsToShow = 3;
  static const avatarRadius = 14.0;
  static const avatarSpacing = 16.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAssignees =
        ref.watch(taskAssignedUsersStreamProvider(taskId)).value ?? [];

    final centerFactor = (avatarsToShow -
            min(taskAssignees.length, avatarsToShow) +
            (taskAssignees.length > avatarsToShow ? 2 : 1)) /
        2;

    return Stack(
      alignment: Alignment.center,
      children: [
        ...List.generate(
          min(taskAssignees.length, avatarsToShow),
          (index) => Positioned(
            left: (index + centerFactor) * avatarSpacing,
            child: UserAvatar(taskAssignees[index], radius: avatarRadius),
          ),
        ),
        if (taskAssignees.length > avatarsToShow)
          Positioned(
            left: avatarsToShow * avatarSpacing,
            child: CircleAvatar(
              radius: avatarRadius,
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Text('+${taskAssignees.length - avatarsToShow}'),
            ),
          ),
      ],
    );
  }
}
