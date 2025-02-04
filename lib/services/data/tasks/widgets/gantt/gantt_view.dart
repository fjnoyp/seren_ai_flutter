// Configurable view for gantt

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/experimental/viewable_tasks_hierarchy_provider.dart';
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

enum GanttViewType { day, week, month }

class GanttView extends HookConsumerWidget {
  final List<String> staticHeadersValues;

  final List<List<String>> staticRowsValues;

  final List<GanttEvent> events;

  final GanttViewType viewType;

  const GanttView({
    super.key,
    required this.staticHeadersValues,
    required this.staticRowsValues,
    required this.events,
    required this.viewType,
  });

  static const double cellHeight = 50.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableWidth =
        MediaQuery.of(context).size.width - 550; // drawer + static
    final cellWidth = switch (viewType) {
      GanttViewType.day => availableWidth / 24,
      GanttViewType.week => availableWidth / 7,
      GanttViewType.month => availableWidth / 30,
    };

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
          //cellWidth: cellWidth,
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
                      viewType: viewType,
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
                        viewType: viewType,
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
  final GanttViewType viewType;

  const GanttHeader({
    super.key,
    required this.cellWidth,
    required this.cellHeight,
    required this.totalWidth,
    required this.columnRange,
    required this.headerController,
    required this.viewType,
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
                  children: switch (viewType) {
                    GanttViewType.day => [
                        _GanttDayHeader(
                          columnRange: columnRange.value,
                          cellWidth: cellWidth,
                          isDayHoursMode: true,
                        ),
                        _GanttHourHeader(
                          columnRange: columnRange.value,
                          cellWidth: cellWidth,
                        ),
                      ],
                    GanttViewType.week => [
                        _GanttWeekHeader(
                          columnRange: columnRange.value,
                          cellWidth: cellWidth,
                        ),
                        _GanttDayHeader(
                          columnRange: columnRange.value,
                          cellWidth: cellWidth,
                        ),
                      ],
                    GanttViewType.month => [
                        _GanttMonthHeader(
                          columnRange: columnRange.value,
                          cellWidth: cellWidth,
                        ),
                        _GanttDayHeader(
                          columnRange: columnRange.value,
                          cellWidth: cellWidth,
                        ),
                      ],
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GanttMonthHeader extends StatelessWidget {
  final (int, int) columnRange;
  final double cellWidth;

  const _GanttMonthHeader({
    required this.columnRange,
    required this.cellWidth,
  });

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    var currentDate = DateTime.now().add(Duration(days: columnRange.$1));
    var currentMonth = DateTime(currentDate.year, currentDate.month);
    var remainingDays = columnRange.$2 - columnRange.$1;

    while (remainingDays > 0) {
      // Calculate days until the end of current month
      final daysInMonth =
          DateTime(currentDate.year, currentDate.month + 1, 0).day;
      final daysUntilMonthEnd = daysInMonth - currentDate.day + 1;
      final daysToShow = remainingDays.clamp(0, daysUntilMonthEnd);

      widgets.add(
        Container(
          width: cellWidth * daysToShow,
          height: 30,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Text(
            DateFormat('MMMM yyyy').format(currentMonth),
            textAlign: TextAlign.center,
          ),
        ),
      );

      remainingDays -= daysToShow;
      currentDate = currentDate.add(Duration(days: daysToShow));
      currentMonth = DateTime(currentDate.year, currentDate.month);
    }

    return Row(children: widgets);
  }
}

class _GanttWeekHeader extends StatelessWidget {
  final (int, int) columnRange;
  final double cellWidth;

  const _GanttWeekHeader({
    required this.columnRange,
    required this.cellWidth,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final baseDate = DateTime(now.year, now.month, now.day);
    final offset = columnRange.$1 - baseDate.weekday + 6;

    return Row(
      children: [
        SizedBox(
            width: (6 - (baseDate.weekday == 7 ? 0 : baseDate.weekday)) *
                cellWidth),
        ...List.generate(
          (columnRange.$2 - columnRange.$1) ~/ 7,
          (weekIndex) {
            final weekStart =
                baseDate.add(Duration(days: weekIndex * 7 + offset));
            final weekEnd = weekStart.add(const Duration(days: 6));

            return Container(
              width: cellWidth * 7,
              height: 30,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Text(
                '${DateFormat('dd MMM yyyy').format(weekStart)} - ${DateFormat('dd MMM yyyy').format(weekEnd)}',
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _GanttDayHeader extends StatelessWidget {
  final (int, int) columnRange;
  final double cellWidth;
  final bool isDayHoursMode;

  const _GanttDayHeader({
    required this.columnRange,
    required this.cellWidth,
    this.isDayHoursMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final cellWidthFactor = isDayHoursMode ? 24 : 1;
    final remainingHoursFromFirstDay =
        24 - ((columnRange.$1 + DateTime.now().hour) % 24 + 24) % 24;
    return Row(children: [
      if (isDayHoursMode)
        SizedBox(width: remainingHoursFromFirstDay * cellWidth),
      ...List.generate(
        ((columnRange.$2 - columnRange.$1) ~/ cellWidthFactor) - 1,
        (index) {
          final date = DateTime.now().add(Duration(
              days: index + (columnRange.$1 / cellWidthFactor).ceil()));

          return Container(
            width: cellWidth * cellWidthFactor,
            height: 30,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              color: (date.weekday == DateTime.saturday ||
                      date.weekday == DateTime.sunday)
                  ? Colors.grey.withAlpha(25)
                  : null,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                isDayHoursMode
                    ? DateFormat('dd MMM yyyy').format(date)
                    : date.day.toString(),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    ]);
  }
}

class _GanttHourHeader extends StatelessWidget {
  final (int, int) columnRange;
  final double cellWidth;

  const _GanttHourHeader({
    required this.columnRange,
    required this.cellWidth,
  });

  @override
  Widget build(BuildContext context) {
    final hourOffset = DateTime.now().hour;
    return Row(
      children: List.generate(
        columnRange.$2 - columnRange.$1,
        (index) {
          // Convert to proper hour of day (0-23)
          final hour = ((index + columnRange.$1 + hourOffset) % 24 + 24) % 24;

          return Container(
            width: cellWidth,
            height: 30,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              color: (hour < 9 || hour > 17) ? Colors.grey.withAlpha(25) : null,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${hour.toString().padLeft(2, '0')}:00',
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
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
  final GanttViewType viewType;

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
    required this.viewType,
  });

  final double cellWidth;
  final double cellHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleTaskIds = ref.watch(curUserViewableTasksHierarchyIdsProvider);

    return SingleChildScrollView(
      controller: mainHorizontalController,
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: totalWidth,
        child: ListView.builder(
          controller: mainVerticalController,
          itemCount: visibleTaskIds.length,
          itemExtent: cellHeight,
          itemBuilder: (context, index) {
            final taskId = visibleTaskIds[index];

            return Stack(
              children: [
                // Background grid
                Container(
                  width: totalWidth - staticHeadersWidth,
                  height: cellHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withAlpha(51)),
                  ),
                ),

                //Task visualization
                GanttTaskDataItemBarView(
                  taskId: taskId,
                  cellWidth: cellWidth,
                  cellHeight: cellHeight,
                  columnStart: columnRange.value.$1,
                  cellDurationType: viewType == GanttViewType.day
                      ? GanttCellDurationType.hours
                      : GanttCellDurationType.days,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
