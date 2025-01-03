import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/shift_logs_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/shift_overrides_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/shift_time_ranges_providers.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/shift_timeframes_provider.dart';

final log = Logger('debugShiftsFullDayView');

const double timeBlockWidth = 50;

Widget debugShiftsFullDayView(String shiftId, DateTime day) {
  return Consumer(
    builder: (context, ref, child) {

      final timeframesAsync = ref.watch(shiftTimeframesProvider(shiftId));
      final logsAsync = ref.watch(curUserShiftLogsProvider((day: day)));
      final overridesAsync = ref.watch(curUserShiftOverridesProvider((day: day)));
      final rangesAsync = ref.watch(curUserShiftTimeRangesProvider((day: day)));

      return AsyncValueHandlerWidget4(
        value1: timeframesAsync,
        value2: logsAsync,
        value3: overridesAsync,
        value4: rangesAsync,
        data: (timeframes, logs, overrides, shiftTimeRanges) {
          return SizedBox(
        height: 450,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight - 30;
            final hourHeight = height / 24;

            return Stack(
              children: [
                // Hour markers and labels
                ...List.generate(25, (index) {
                  final isMainMarker = index % 6 == 0;
                  return Stack(
                    children: [
                      Positioned(
                        top: index * hourHeight,
                        left: 20,
                        right: 0,
                        child: Divider(
                          color: isMainMarker ? Colors.blue : Colors.grey[300],
                          thickness: isMainMarker ? 2 : 1,
                        ),
                      ),
                      if (isMainMarker)
                        Positioned(
                          top: index * hourHeight, // Adjust for text alignment
                          left: 0,
                          child: SizedBox(
                            width: 15,
                            height: 20,
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                    ],
                  );
                }),

                // Timeframes
                ...(timeframes).map((timeFrame) {
                  if (timeFrame.dayOfWeek != day.weekday) {
                    return const SizedBox.shrink();
                  }
                  final start = timeFrame.getStartDateTime(day).toLocal();
                  final end = start.add(timeFrame.duration);
                  return _buildTimeBlock(
                    day: day,
                    startTime: start,
                    endTime: end,
                    totalHeight: height,
                    hourHeight: hourHeight,
                    color: Colors.blue.withAlpha(128),
                    label: 'SHIFT: \n${_formatTimeRange(start, end)}',
                  );
                }),

                // Overrides
                ...(overrides).map((override) {
                  final start = override.startDateTime.toLocal();
                  final end = override.endDateTime.toLocal();
                  final color = override.isRemoval
                      ? Colors.red.withAlpha(128)
                      : Colors.orange.withAlpha(128);
                  return _buildTimeBlock(
                    day: day,
                    startTime: start,
                    endTime: end,
                    totalHeight: height,
                    hourHeight: hourHeight,
                    color: color,
                    label: 'OVERRIDE: \n${_formatTimeRange(start, end)}',
                    leftOffset: timeBlockWidth,
                  );
                }),

                // Logs
                ...(logs).map((log) {
                  final start = log.clockInDatetime.toLocal();
                  final end = log.clockOutDatetime?.toLocal() ?? DateTime.now();
                  final color = log.isBreak
                      ? Colors.yellow.withAlpha(128)
                      : Colors.green.withAlpha(128);
                  return _buildTimeBlock(
                    day: day,
                    startTime: start,
                    endTime: end,
                    totalHeight: height,
                    hourHeight: hourHeight,
                    color: color,
                    label: 'LOG: \n${_formatTimeRange(start, end)}',
                    leftOffset: 2 * timeBlockWidth,
                  );
                }),

                ...(shiftTimeRanges).map((range) {
                  final start = range.start.toLocal();
                  final end = range.end.toLocal();
                  return _buildTimeBlock(
                    day: day,
                    startTime: start,
                    endTime: end,
                    totalHeight: height,
                    hourHeight: hourHeight,
                    color: Colors.blue.withAlpha(128),
                    label: 'actual shift: \n${_formatTimeRange(start, end)}',
                    leftOffset: 3 * timeBlockWidth,
                  );
                }),

                // Draw a line at the current time
                _drawLineAtCurrentTime(day, hourHeight),
              ],
            );
          },
        ),
      );
        },
      );

      
    },
  );
}

Widget _drawLineAtCurrentTime(DateTime day, double hourHeight) {
  final startTime = DateTime.now();

  if (startTime.day != day.day) {
    return const SizedBox.shrink();
  }

  final startOffset = startTime.hour * 60 + startTime.minute;
  final top = (startOffset / 60) * hourHeight;

  return Positioned(
    top: top,
    left: 20,
    right: 0,
    child: const Divider(
      color: Colors.red,
      thickness: 2,
    ),
  );
}

String _formatTimeRange(DateTime startTime, DateTime endTime) {
  return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
}

Widget _buildTimeBlock({
  required DateTime day,
  required DateTime startTime,
  required DateTime endTime,
  required double totalHeight,
  required double hourHeight,
  required Color color,
  required String label,
  double width = timeBlockWidth,
  double leftOffset = 0,
}) {
  // if startTime or endTime are not on the same day as day, return null
  if (startTime.day > day.day || endTime.day < day.day) {
    // Ignore this case for now - we need to handle multi day shift info
    log.severe(
        'unhandled edge case for start and end time not on the same day as day');
    return const SizedBox.shrink();
  }

  final startOffset =
      startTime.day < day.day ? 0 : startTime.hour * 60 + startTime.minute;
  final endOffset =
      endTime.day > day.day ? (24 * 60) : endTime.hour * 60 + endTime.minute;
  final top = (startOffset / 60) * hourHeight;
  final blockHeight = ((endOffset - startOffset) / 60) * hourHeight;

  return Positioned(
    left: 20 + leftOffset, // Adjust to align with hour markers
    top: top,
    //right: 0,
    child: Container(
      width: width,
      height: blockHeight,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ),
  );
}
