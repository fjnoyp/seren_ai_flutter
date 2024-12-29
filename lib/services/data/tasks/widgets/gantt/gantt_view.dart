// Configurable view for gantt

import 'dart:async';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

// How are left side values given?

// Header description
// Need a list of headers and their widths

// Body description
// Need a list of header values and the date values

class GanttEvent {
  final String title;
  final DateTime startDate;
  final Duration duration;
  final Color color;

  GanttEvent({
    required this.title,
    required this.startDate,
    required DateTime endDate,
    required this.color,
  }) : duration = endDate.difference(startDate) {
    // final colorValue = title.hashCode;
    // final hue = (colorValue % 360).abs().toDouble();
    // color = HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
  }
}

class GanttView extends HookWidget {
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

  double calculateEventPosition(DateTime date, int start) {
    final startDate = DateTime.now().add(Duration(days: start));
    final difference = date.difference(startDate).inDays;
    return difference * cellWidth;
  }

  @override
  Widget build(BuildContext context) {
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

        print('currentScroll: $currentScroll');
        print('maxScroll: $maxScroll');

        final isScrollingLeft =
            position.userScrollDirection == ScrollDirection.forward;

        // Moving Right
        if (!isScrollingLeft && currentScroll > maxScroll * 0.95) {
          isLoadingRight.value = true;

          Future.microtask(() {
            print('loading more right!');
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
            print('loading more left!');
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
        StaticColumn(
          headers: staticHeadersValues,
          staticRowsValues: staticRowsValues,
          rowCount: rowCount.value,
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
                    // Header
                    SizedBox(
                      height: 60,
                      child: Row(
                        children: [
                          dateHeaders(
                              totalWidth: totalWidth,
                              columnRange: columnRange,
                              headerController: headerController,
                              context: context),
                        ],
                      ),
                    ),

                    // Body
                    Expanded(
                      child: Row(
                        children: [
                          body(
                              mainHorizontalController:
                                  mainHorizontalController,
                              totalWidth: totalWidth,
                              mainVerticalController: mainVerticalController,
                              rowCount: rowCount.value,
                              columnRange: columnRange,
                              events: events,
                              staticHeadersWidth: staticHeadersWidth,
                              context: context),
                        ],
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

  Widget dateHeaders({
    required double totalWidth,
    required ValueNotifier<(int, int)> columnRange,
    required ScrollController headerController,
    required BuildContext context,
  }) {
    return Expanded(
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
                    final weekStart = DateTime.now().add(
                        Duration(days: weekIndex * 7 + columnRange.value.$1));
                    final weekEnd = weekStart.add(const Duration(days: 6));
                    return Container(
                      width: cellWidth * 7,
                      height: 30,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Theme.of(context).dividerColor),
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
                    final date = DateTime.now()
                        .add(Duration(days: index + columnRange.value.$1));
                    return Container(
                      width: cellWidth,
                      height: 30,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Theme.of(context).dividerColor),
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
    );
  }

  Widget body({
    required ScrollController mainHorizontalController,
    required double totalWidth,
    required ScrollController mainVerticalController,
    required int rowCount,
    required ValueNotifier<(int, int)> columnRange,
    required List<GanttEvent> events,
    required double staticHeadersWidth,
    required BuildContext context,
  }) {
    return Expanded(
      child: SingleChildScrollView(
        controller: mainHorizontalController,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalWidth,
          child: ListView.builder(
            controller: mainVerticalController,
            itemCount: rowCount,
            itemExtent: cellHeight,
            itemBuilder: (context, rowIndex) {
              // Find event for this row if it exists
              final event = events.length > rowIndex ? events[rowIndex] : null;

              return Stack(
                children: [
                  // Background grid lines (optional)
                  Container(
                    width: totalWidth - staticHeadersWidth,
                    height: cellHeight,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                  ),

                  // Event bar (if exists)
                  if (event != null)
                    Positioned(
                      left: calculateEventPosition(
                          event.startDate, columnRange.value.$1),
                      top: 5,
                      child: Container(
                        width: event.duration.inDays * cellWidth,
                        height: cellHeight - 10,
                        decoration: BoxDecoration(
                          color: event.color ?? Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            event.title,
                            style: const TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class StaticColumn extends StatelessWidget {
  final ScrollController? verticalController;
  final List<String> headers;
  final List<List<String>> staticRowsValues;
  final int rowCount;
  final double cellWidth;
  final double cellHeight;
  final ScrollController mainVerticalController;

  const StaticColumn({
    super.key,
    required this.headers,
    required this.staticRowsValues,
    required this.rowCount,
    required this.cellWidth,
    required this.cellHeight,
    this.verticalController,
    required this.mainVerticalController,
  });

  @override
  Widget build(BuildContext context) {
    // Listener / GestureDetector allows scrolls here to trigger changes to the mainVerticalController
    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          mainVerticalController.position.moveTo(
            mainVerticalController.offset + pointerSignal.scrollDelta.dy,
            clamp: true,
          );
        }
      },
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          mainVerticalController.position.moveTo(
            mainVerticalController.offset - details.delta.dy,
            clamp: true,
          );
        },
        child: SizedBox(
          width: headers.length * cellWidth,
          child: Column(
            children: [
              // Headers
              SizedBox(
                height: 60,
                child: Row(
                  children: headers
                      .map((header) => _buildHeaderCell(header))
                      .toList(),
                ),
              ),
              // Rows
              Expanded(
                child: Row(
                  children: List.generate(
                    headers.length,
                    (columnIndex) => _buildColumn(context, columnIndex),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String header) {
    return Container(
      width: cellWidth,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(border: Border.all()),
      child: Text(header),
    );
  }

  Widget _buildColumn(BuildContext context, int columnIndex) {
    return SizedBox(
      width: cellWidth,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          controller: verticalController,
          itemCount: rowCount,
          itemExtent: cellHeight,
          itemBuilder: (context, rowIndex) =>
              _buildRowCell(rowIndex, columnIndex),
        ),
      ),
    );
  }

  Widget _buildRowCell(int rowIndex, int columnIndex) {
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
