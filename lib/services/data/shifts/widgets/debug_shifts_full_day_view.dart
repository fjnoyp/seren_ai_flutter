import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/joined_shift_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/cur_shifts/shift_day_fam_listener_providers/cur_user_shift_timeframes_shift_fam_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/cur_shifts/shift_day_fam_listener_providers/cur_user_shift_logs_fam_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/cur_shifts/shift_day_fam_listener_providers/cur_user_shift_overrides_fam_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/cur_shifts/cur_user_active_shift_ranges_fam_provider.dart';

final log = Logger('debugShiftsFullDayView');

const double timeBlockWidth = 50;

Widget debugShiftsFullDayView(String shiftId, DateTime day) {
  return Consumer(
    builder: (context, ref, child) {
      // TODO p5: split providers so one update doesn't trigger entire rebuild 

      final timeframes = ref.watch(curUserShiftTimeframesFamListenerProvider(shiftId));
      final logs = ref.watch(curUserShiftLogsFamListenerProvider((shiftId: shiftId, day: day)));
      final overrides = ref.watch(curUserShiftOverridesFamListenerProvider((shiftId: shiftId, day: day)));
      final shiftTimeRanges = ref.watch(curUserActiveShiftRangesFamProvider((shiftId: shiftId, day: day)));

      return SizedBox(
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
                              '${index.toString().padLeft(2, '0')}',
                              style: TextStyle(fontSize: 10),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                    ],
                  );
                }),

                // Timeframes
                ...(timeframes ?? []).map((timeFrame) {
                  if(timeFrame.dayOfWeek != day.weekday) {
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
                    color: Colors.blue.withOpacity(0.5),
                    label: 'SHIFT: \n${_formatTimeRange(start, end)}',
                  );
                }),

                // Overrides
                ...(overrides ?? []).map((override) {
                  final start = override.startDateTime.toLocal();
                  final end = override.endDateTime.toLocal();
                  final color = override.isRemoval
                      ? Colors.red.withOpacity(0.5)
                      : Colors.orange.withOpacity(0.5);
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
                ...(logs ?? []).map((log) {
                  final start = log.clockInDatetime.toLocal();
                  final end = log.clockOutDatetime?.toLocal() ?? DateTime.now();
                  final color = log.isBreak
                      ? Colors.yellow.withOpacity(0.5)
                      : Colors.green.withOpacity(0.5);
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

                ...shiftTimeRanges.map((range) {
                  final start = range.start.toLocal();
                  final end = range.end.toLocal();
                  return _buildTimeBlock(
                    day: day,
                    startTime: start, 
                    endTime: end, 
                    totalHeight: height,
                    hourHeight: hourHeight,
                    color: Colors.blue.withOpacity(0.5),
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
    child: Divider(
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
    log.severe('unhandled edge case for start and end time not on the same day as day');
    return const SizedBox.shrink();
  }

  final startOffset = startTime.day < day.day ? 0 : startTime.hour * 60 + startTime.minute;
  final endOffset = endTime.day > day.day ? (24*60) : endTime.hour * 60 + endTime.minute;
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
            style: TextStyle(fontSize: 10, color: Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ),
  );
}
