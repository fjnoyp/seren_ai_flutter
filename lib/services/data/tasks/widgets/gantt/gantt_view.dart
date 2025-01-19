// Configurable view for gantt

import 'dart:async';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/gantt_providers.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/gantt_static_column_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/gantt_task_data_item_bar_view.dart';

// How are left side values given?

// Header description
// Need a list of headers and their widths

// Body description
// Need a list of header values and the date values

class GanttEvent {
  final String title;
  final DateTime? startDate;
  final DateTime? endDate;
  final Duration? duration;
  final Color color;

  GanttEvent({
    required this.title,
    this.startDate,
    this.endDate,
    required this.color,
  }) : duration = (startDate != null && endDate != null)
            ? endDate.difference(startDate)
            : null;
}

class GanttView extends HookConsumerWidget {
  final List<String> staticHeadersValues;
  final List<List<String>> staticRowsValues;

  final List<GanttEvent> events;

  const GanttView({
    super.key,
    required this.staticHeadersValues,
    required this.staticRowsValues,
    required this.events,
  });

  static const double cellWidth = 100.0;
  static const double cellHeight = 50.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mainHorizontalController = useScrollController();
    final mainVerticalController = useScrollController();
    final headerController = useScrollController();
    final leftController = useScrollController();

    final columnRange = useState<(int, int)>((-90, 90));
    final rowCount = useState(50);
    final isLoadingLeft = useState(false);
    final isLoadingRight = useState(false);
    final isLoadingMoreRows = useState(false);

    // Automaticaly center the scroll on first load
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mainHorizontalController.hasClients) {
          final position = mainHorizontalController.position;
          final maxScroll = position.maxScrollExtent;
          final middlePosition = maxScroll / 2;
          mainHorizontalController.jumpTo(middlePosition);
        }
      });
      return null;
    }, []);

    useEffect(() {
      void syncScrolls() {
        headerController.jumpTo(mainHorizontalController.offset);
        leftController.jumpTo(mainVerticalController.offset);
      }

      void handleHorizontalInfiniteScroll() {
        if (isLoadingLeft.value || isLoadingRight.value) return;

        final position = mainHorizontalController.position;
        final maxScroll = position.maxScrollExtent;
        final currentScroll = position.pixels;

        final isScrollingLeft =
            position.userScrollDirection == ScrollDirection.forward;

        // Moving Right
        if (!isScrollingLeft && currentScroll > maxScroll * 0.95) {
          isLoadingRight.value = true;

          Future.microtask(() {
            final (start, end) = columnRange.value;
            columnRange.value = (start, end + 90);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mainHorizontalController.hasClients) {
                mainHorizontalController.jumpTo(currentScroll);
              }
              isLoadingRight.value = false;
            });
          });

          // Moving Left
        } else if (isScrollingLeft && currentScroll <= maxScroll * 0.05) {
          isLoadingLeft.value = true;
          final previousStart = columnRange.value.$1;

          Future.microtask(() {
            final (start, end) = columnRange.value;
            columnRange.value = (start - 90, end);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              final offset = (previousStart - columnRange.value.$1) * cellWidth;
              if (mainHorizontalController.hasClients) {
                mainHorizontalController
                    .jumpTo(mainHorizontalController.offset + offset);
              }
              isLoadingLeft.value = false;
            });
          });
        }
      }

      void handleVerticalInfiniteScroll() {
        if (isLoadingMoreRows.value) return;

        final position = mainVerticalController.position;
        final maxScroll = position.maxScrollExtent;
        final currentScroll = position.pixels;

        if (maxScroll - currentScroll <= 500) {
          isLoadingMoreRows.value = true;
          Future.microtask(() {
            rowCount.value += 25;
            isLoadingMoreRows.value = false;
          });
        }
      }

      mainHorizontalController.addListener(syncScrolls);
      mainVerticalController.addListener(syncScrolls);
      mainHorizontalController.addListener(handleHorizontalInfiniteScroll);
      mainVerticalController.addListener(handleVerticalInfiniteScroll);

      return () {
        mainHorizontalController.removeListener(syncScrolls);
        mainVerticalController.removeListener(syncScrolls);
        mainHorizontalController.removeListener(handleHorizontalInfiniteScroll);
        mainVerticalController.removeListener(handleVerticalInfiniteScroll);
      };
    }, [mainHorizontalController, mainVerticalController]);

    final staticHeadersWidth = useMemoized(
        () => staticHeadersValues.length * cellWidth, [staticHeadersValues]);

    final totalWidth = useMemoized(
        () =>
            (columnRange.value.$2 - columnRange.value.$1) * cellWidth +
            staticHeadersWidth,
        [columnRange.value, staticHeadersWidth]);

    return Row(
      children: [
        GanttStaticColumnView(
          //headers: staticHeadersValues,
          //staticRowsValues: staticRowsValues,
          //rowCount: rowCount.value,
          cellWidth: cellWidth,
          cellHeight: cellHeight,
          verticalController: leftController,
          mainVerticalController: mainVerticalController,
        ),
        Expanded(
          child: Scrollbar(
            controller: mainVerticalController,
            thumbVisibility: true,
            trackVisibility: true,
            child: Scrollbar(
              controller: mainHorizontalController,
              thumbVisibility: true,
              trackVisibility: true,
              scrollbarOrientation: ScrollbarOrientation.bottom,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: Column(
                  children: [
                    GanttHeader(
                      cellWidth: cellWidth,
                      cellHeight: 60,
                      totalWidth: totalWidth,
                      columnRange: columnRange,
                      headerController: headerController,
                    ),

                    // Body
                    Expanded(
                      child: GanttBody(
                        //events: events,
                        cellWidth: cellWidth,
                        cellHeight: cellHeight,
                        mainHorizontalController: mainHorizontalController,
                        totalWidth: totalWidth,
                        mainVerticalController: mainVerticalController,
                        rowCount: rowCount.value,
                        columnRange: columnRange,
                        staticHeadersWidth: staticHeadersWidth,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GanttHeader extends StatelessWidget {
  final double cellWidth;
  final double cellHeight;
  final double totalWidth;
  final ValueNotifier<(int, int)> columnRange;
  final ScrollController headerController;

  const GanttHeader({
    super.key,
    required this.cellWidth,
    required this.cellHeight,
    required this.totalWidth,
    required this.columnRange,
    required this.headerController,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cellHeight,
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: headerController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: totalWidth,
                child: Column(
                  children: [
                    // Week range row
                    Row(
                      children: List.generate(
                        (columnRange.value.$2 - columnRange.value.$1) ~/ 7,
                        (weekIndex) {
                          final weekStart = DateTime.now().add(Duration(
                              days: weekIndex * 7 + columnRange.value.$1));
                          final weekEnd =
                              weekStart.add(const Duration(days: 6));
                          return Container(
                            width: cellWidth * 7,
                            height: 30,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).dividerColor),
                            ),
                            child: Text(
                              '${DateFormat('dd MMM yyyy').format(weekStart)} - ${DateFormat('dd MMM yyyy').format(weekEnd)}',
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                    // Day numbers row
                    Row(
                      children: List.generate(
                        columnRange.value.$2 - columnRange.value.$1,
                        (index) {
                          final date = DateTime.now().add(
                              Duration(days: index + columnRange.value.$1));
                          return Container(
                            width: cellWidth,
                            height: 30,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).dividerColor),
                              color: (date.weekday == DateTime.saturday ||
                                      date.weekday == DateTime.sunday)
                                  ? Colors.grey.withOpacity(0.1)
                                  : null,
                            ),
                            child: Text(
                              date.day.toString(),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// New separate widget for the body
class GanttBody extends ConsumerWidget {
  final ScrollController mainHorizontalController;
  final double totalWidth;
  final ScrollController mainVerticalController;
  final int rowCount;
  final ValueNotifier<(int, int)> columnRange;
  final double staticHeadersWidth;

  const GanttBody({
    super.key,
    required this.mainHorizontalController,
    required this.totalWidth,
    required this.mainVerticalController,
    required this.rowCount,
    required this.columnRange,
    required this.staticHeadersWidth,
    required this.cellWidth,
    required this.cellHeight,
  });

  final double cellWidth;
  final double cellHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleTasks = ref.watch(visibleGanttTasksProvider);

    return SingleChildScrollView(
      controller: mainHorizontalController,
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: totalWidth,
        child: ListView.builder(
          controller: mainVerticalController,
          itemCount: visibleTasks.length,
          itemExtent: cellHeight,
          itemBuilder: (context, index) {
            final task = visibleTasks[index];

            return Stack(
              children: [
                // Background grid
                Container(
                  width: totalWidth - staticHeadersWidth,
                  height: cellHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                ),

                //Task visualization
                GanttTaskDataItemBarView(
                  task: task,
                  cellWidth: cellWidth,
                  cellHeight: cellHeight,
                  columnStartDay: columnRange.value.$1,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
