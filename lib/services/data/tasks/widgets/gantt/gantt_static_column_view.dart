import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/gantt_providers.dart';

class GanttStaticColumnView extends ConsumerWidget {
  final ScrollController? verticalController;
  final double cellWidth;
  final double cellHeight;
  final ScrollController mainVerticalController;

  const GanttStaticColumnView({
    super.key,
    required this.cellWidth,
    required this.cellHeight,
    this.verticalController,
    required this.mainVerticalController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleTasks = ref.watch(visibleGanttTasksProvider);

    final staticRowValues = visibleTasks.map((task) => [task.title]).toList();

    final numColumns = staticRowValues[0].length;

    return Listener(
      onPointerSignal: _handlePointerScroll,
      child: GestureDetector(
        onVerticalDragUpdate: _handleVerticalDrag,
        child: SizedBox(
          width: numColumns * cellWidth,
          child: Column(
            children: [
              _StaticHeader(
                columnCount: numColumns,
                cellWidth: cellWidth,
              ),
              _StaticRows(
                columnCount: numColumns,
                staticRowsValues: staticRowValues,
                visibleTaskCount: visibleTasks.length,
                cellWidth: cellWidth,
                cellHeight: cellHeight,
                verticalController: verticalController,
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
  final int columnCount;
  final double cellWidth;

  const _StaticHeader({
    required this.columnCount,
    required this.cellWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        children: List.generate(
            columnCount,
            (index) => Container(
                  width: cellWidth,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(border: Border.all()),
                  child: Text('Column ${index + 1}'),
                )),
      ),
    );
  }
}

class _StaticRows extends StatelessWidget {
  final int columnCount;
  final List<List<String>> staticRowsValues;
  final int visibleTaskCount;
  final double cellWidth;
  final double cellHeight;
  final ScrollController? verticalController;

  const _StaticRows({
    required this.columnCount,
    required this.staticRowsValues,
    required this.visibleTaskCount,
    required this.cellWidth,
    required this.cellHeight,
    required this.verticalController,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: List.generate(
          columnCount,
          (columnIndex) => _StaticColumn(
            columnIndex: columnIndex,
            staticRowsValues: staticRowsValues,
            //visibleTaskCount: visibleTaskCount,
            cellWidth: cellWidth,
            cellHeight: cellHeight,
            verticalController: verticalController,
          ),
        ),
      ),
    );
  }
}

class _StaticColumn extends StatelessWidget {
  final int columnIndex;
  final List<List<String>> staticRowsValues;

  final double cellWidth;
  final double cellHeight;
  final ScrollController? verticalController;

  const _StaticColumn({
    required this.columnIndex,
    required this.staticRowsValues,
    required this.cellWidth,
    required this.cellHeight,
    required this.verticalController,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cellWidth,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          controller: verticalController,
          itemCount: staticRowsValues.length,
          itemExtent: cellHeight,
          itemBuilder: (context, rowIndex) => _StaticCell(
            rowIndex: rowIndex,
            columnIndex: columnIndex,
            staticRowsValues: staticRowsValues,
            cellHeight: cellHeight,
          ),
        ),
      ),
    );
  }
}

class _StaticCell extends StatelessWidget {
  final int rowIndex;
  final int columnIndex;
  final List<List<String>> staticRowsValues;
  final double cellHeight;

  const _StaticCell({
    required this.rowIndex,
    required this.columnIndex,
    required this.staticRowsValues,
    required this.cellHeight,
  });

  @override
  Widget build(BuildContext context) {
    final cellValue = staticRowsValues.length > rowIndex &&
            staticRowsValues[rowIndex].length > columnIndex
        ? staticRowsValues[rowIndex][columnIndex]
        : '';

    return Container(
      height: cellHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(border: Border.all()),
      child: Text(cellValue),
    );
  }
}
