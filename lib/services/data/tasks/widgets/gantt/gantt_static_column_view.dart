import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/form/task_selection_fields.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/experimental/viewable_tasks_hierarchy_provider.dart';

class GanttStaticColumnView extends ConsumerWidget {
  static const Map<TaskFieldEnum, double> columnWidths = {
    TaskFieldEnum.name: 80.0,
    TaskFieldEnum.status: 60.0,
    TaskFieldEnum.priority: 60.0,
    TaskFieldEnum.assignees: 150.0,
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
      TaskFieldEnum.status,
      TaskFieldEnum.priority,
      TaskFieldEnum.assignees
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

  const _StaticHeader({
    required this.staticColumnHeaders,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        children: List.generate(
          staticColumnHeaders.length,
          (index) => Container(
            width:
                GanttStaticColumnView.columnWidths[staticColumnHeaders[index]]!,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(border: Border.all()),
            child: Text(
              staticColumnHeaders[index]
                  .toString()
                  .split('.')
                  .last, // Display enum name
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
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
          child: ListView.builder(
            physics: const ClampingScrollPhysics(),
            controller: verticalController,
            itemCount: taskIds.length,
            itemExtent: cellHeight,
            cacheExtent: 200,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            itemBuilder: (context, rowIndex) => _StaticRow(
              taskId: taskIds[rowIndex],
              cellHeight: cellHeight,
              staticColumnHeaders: staticColumnHeaders,
            ),
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
      loading: () => const Center(child: CircularProgressIndicator()),
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
      width: GanttStaticColumnView.columnWidths[fieldType]!,
      height: cellHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(border: Border.all()),
      child: _StaticCellContent(
        taskId: taskId,
        fieldType: fieldType,
      ),
    );
  }
}

class _StaticCellContent extends StatelessWidget {
  final String taskId;
  final TaskFieldEnum fieldType;

  const _StaticCellContent({
    required this.taskId,
    required this.fieldType,
  });

  @override
  Widget build(BuildContext context) {
    switch (fieldType) {
      case TaskFieldEnum.name:
        return TaskNameField(
          taskId: taskId,
          textStyle: Theme.of(context).textTheme.bodyMedium,
        );
      case TaskFieldEnum.status:
        return TaskStatusSelectionField(
          taskId: taskId,
          showLabelWidget: false,
        );
      case TaskFieldEnum.priority:
        return TaskPrioritySelectionField(
          taskId: taskId,
          showLabelWidget: false,
        );
      case TaskFieldEnum.assignees:
        return TaskAssigneesSelectionField(taskId: taskId);
      default:
        return const SizedBox.shrink();
    }
  }
}
