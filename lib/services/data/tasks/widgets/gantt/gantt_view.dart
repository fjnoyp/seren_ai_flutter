// Configurable view for gantt

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/experimental/cur_project_tasks_hierarchy_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/experimental/gantt_task_visual_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/gantt_static_column_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/gantt_task_data_item_bar_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  final ScrollController? horizontalScrollController;
  final ScrollController? verticalScrollController;

  const GanttView({
    super.key,
    required this.staticHeadersValues,
    required this.staticRowsValues,
    required this.events,
    required this.viewType,
    this.horizontalScrollController,
    this.verticalScrollController,
  });

  static const double cellHeight = 50.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableWidth =
        MediaQuery.of(context).size.width - 590; // drawer + static
    final cellWidth = switch (viewType) {
      GanttViewType.day => availableWidth / 24,
      GanttViewType.week => availableWidth / 7,
      GanttViewType.month => availableWidth / 30,
    };

    final mainHorizontalController =
        horizontalScrollController ?? useScrollController();
    final mainVerticalController =
        verticalScrollController ?? useScrollController();
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

    // Add a function to navigate to a specific task's timeframe
    void navigateToTaskTimeframe(String taskId) {
      final taskAsync = ref.read(taskByIdStreamProvider(taskId));

      taskAsync.whenData((task) {
        if (task == null) return;

        // Determine which date to use (start date preferred, fallback to due date)
        final targetDate = task.startDateTime ?? task.dueDate;
        if (targetDate == null) return;

        // Get current date range from the Gantt chart
        final (currentStartUnit, currentEndUnit) = columnRange.value;
        final visibleUnits = currentEndUnit - currentStartUnit;
        final buffer = visibleUnits ~/ 4;

        // Calculate view start date based on view type
        final viewStartDate = DateTime.now().add(Duration(
            days: viewType == GanttViewType.day ? 0 : currentStartUnit,
            hours: viewType == GanttViewType.day ? currentStartUnit : 0));

        // Calculate target offset based on view type
        final targetOffset = viewType == GanttViewType.day
            ? targetDate.difference(viewStartDate).inHours
            : targetDate.difference(viewStartDate).inDays;

        // Check if target is within visible range
        final needsRangeAdjustment =
            targetOffset < 0 || targetOffset > visibleUnits;

        // Calculate new start unit if adjustment needed
        int newStartUnit = currentStartUnit;

        if (needsRangeAdjustment) {
          if (viewType == GanttViewType.week) {
            // Align to week boundaries (start on Monday)
            final targetWeekStart =
                targetDate.subtract(Duration(days: targetDate.weekday - 1));
            newStartUnit = targetWeekStart.difference(DateTime.now()).inDays;
          } else if (viewType == GanttViewType.month) {
            // Align to month boundaries (start on 1st of month)
            final targetMonthStart =
                DateTime(targetDate.year, targetDate.month, 1);
            newStartUnit = targetMonthStart.difference(DateTime.now()).inDays;
          } else {
            // Day view or default
            newStartUnit = currentStartUnit + targetOffset - buffer;
          }

          // Update column range
          columnRange.value = (newStartUnit, newStartUnit + visibleUnits);
        }

        // Scroll to the target position
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mainHorizontalController.hasClients) {
            // Calculate the position to scroll to
            double scrollPosition;

            if (needsRangeAdjustment) {
              // If we adjusted the range, calculate new position
              final adjustedViewStartDate = DateTime.now().add(Duration(
                  days: viewType == GanttViewType.day ? 0 : newStartUnit,
                  hours: viewType == GanttViewType.day ? newStartUnit : 0));

              final adjustedOffset = viewType == GanttViewType.day
                  ? targetDate.difference(adjustedViewStartDate).inHours
                  : targetDate.difference(adjustedViewStartDate).inDays;

              scrollPosition = adjustedOffset * cellWidth;
            } else {
              // Use original offset if no adjustment was needed
              scrollPosition = targetOffset * cellWidth;
            }

            // Show 3 units (days or hours) before the task date
            final contextBuffer = 3 * cellWidth;

            mainHorizontalController.animateTo(
              max(0, scrollPosition - contextBuffer),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });
      });
    }

    return Row(
      children: [
        GanttStaticColumnView(
          cellHeight: cellHeight,
          verticalController: leftController,
          mainVerticalController: mainVerticalController,
          onNavigateToTask: navigateToTaskTimeframe,
        ),
        const VerticalDivider(width: 1),
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
    final projectTaskIds = ref.watch(curProjectTasksHierarchyIdsProvider);

    return SingleChildScrollView(
      controller: mainHorizontalController,
      scrollDirection: Axis.horizontal,
      child: LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          width: totalWidth - staticHeadersWidth,
          height: constraints.maxHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ListView.separated(
                controller: mainVerticalController,
                itemCount: projectTaskIds.length,
                itemBuilder: (context, index) {
                  final taskId = projectTaskIds[index];
                  final isVisible =
                      ref.watch(ganttTaskVisibilityProvider(taskId));

                  return isVisible
                      ? Stack(
                          children: [
                            // Add a transparent detector for tasks without dates
                            _EmptyTaskDetector(
                              taskId: taskId,
                              cellWidth: cellWidth,
                              cellHeight: cellHeight,
                              columnStart: columnRange.value.$1,
                              cellDurationType: viewType == GanttViewType.day
                                  ? GanttCellDurationType.hours
                                  : GanttCellDurationType.days,
                            ),
                            SizedBox(height: cellHeight),
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
                        )
                      : const SizedBox.shrink();
                },
                separatorBuilder: (context, index) {
                  final isTaskVisible = ref.watch(
                      ganttTaskVisibilityProvider(projectTaskIds[index]));
                  return isTaskVisible
                      ? const Divider(height: 1)
                      : const SizedBox.shrink();
                },
              ),
              Positioned(
                left: cellWidth * -columnRange.value.$1,
                child: Container(
                  height: constraints.maxHeight,
                  width: 1,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// New widget to detect hover and tap for tasks without dates
class _EmptyTaskDetector extends HookConsumerWidget {
  final String taskId;
  final double cellWidth;
  final double cellHeight;
  final int columnStart;
  final GanttCellDurationType cellDurationType;

  const _EmptyTaskDetector({
    required this.taskId,
    required this.cellWidth,
    required this.cellHeight,
    required this.columnStart,
    required this.cellDurationType,
  });

  DateTime _calculateDateFromPosition(double position) {
    final now = DateTime.now();
    final startDateTime = DateTime(now.year, now.month, now.day, now.hour).add(
      Duration(
        days: cellDurationType == GanttCellDurationType.days ? columnStart : 0,
        hours: cellDurationType == GanttCellDurationType.days ? 0 : columnStart,
      ),
    );

    final cellsFromStart = position / cellWidth;

    return startDateTime.add(
      Duration(
        days: cellDurationType == GanttCellDurationType.days
            ? cellsFromStart.floor()
            : 0,
        hours: cellDurationType == GanttCellDurationType.days
            ? 0
            : cellsFromStart.floor(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHovering = useState(false);
    final hoverX = useState(0.0);
    final taskAsync = ref.watch(taskByIdStreamProvider(taskId));

    return taskAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (task) {
        if (task == null) return const SizedBox.shrink();

        // Only show for tasks without both start and end dates
        final hasStartDate = task.startDateTime != null;
        final hasEndDate = task.dueDate != null;

        if (hasStartDate || hasEndDate) return const SizedBox.shrink();

        return MouseRegion(
          onHover: (event) {
            isHovering.value = true;
            hoverX.value = event.localPosition.dx;
          },
          onExit: (_) {
            isHovering.value = false;
          },
          child: GestureDetector(
            onTapUp: (details) {
              final date = _calculateDateFromPosition(details.localPosition.dx);
              ref.read(tasksRepositoryProvider).updateTaskStartDateTime(
                    task.id,
                    date,
                  );
            },
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: cellHeight,
                  color: Colors.transparent,
                ),
                if (isHovering.value)
                  Positioned(
                    left: hoverX.value,
                    child: Container(
                      width: 2,
                      height: cellHeight,
                      color:
                          Theme.of(context).colorScheme.primary.withAlpha(180),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: -25,
                            left: -40,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                DateFormat(
                                        cellDurationType ==
                                                GanttCellDurationType.days
                                            ? 'MMM d, yyyy'
                                            : 'MMM d, HH:mm',
                                        AppLocalizations.of(context)!
                                            .localeName)
                                    .format(_calculateDateFromPosition(
                                        hoverX.value)),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
