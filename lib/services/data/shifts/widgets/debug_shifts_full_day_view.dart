import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/joined_shift_model.dart';

Widget debugShiftsFullDayView(DateTime day, JoinedShiftModel shift) {
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
            ...shift.timeFrames.map((timeFrame) {
              final start = _parseTime(timeFrame.startTime);
              final end = start.add(timeFrame.duration);
              return _buildTimeBlock(
                startTime: start,
                endTime: end,
                totalHeight: height,
                hourHeight: hourHeight,
                color: Colors.blue.withOpacity(0.5),
                label: 'SHIFT: \n${_formatTimeRange(start, end)}',
              );
            }),

            // Overrides
            ...shift.overrides.map((override) {
              final start = override.startDatetime.toLocal();
              final end = override.endDatetime.toLocal();
              final color = override.isRemoval
                  ? Colors.red.withOpacity(0.5)
                  : Colors.orange.withOpacity(0.5);
              return _buildTimeBlock(
                startTime: start,
                endTime: end,
                totalHeight: height,
                hourHeight: hourHeight,
                color: color,
                label: 'OVERRIDE: \n${_formatTimeRange(start, end)}',
                leftOffset: 100,
              );
            }),

            // Logs
            ...shift.logs.map((log) {
              final start = log.clockInDatetime.toLocal();
              final end = log.clockOutDatetime?.toLocal() ?? DateTime.now();
              final color = log.isBreak
                  ? Colors.yellow.withOpacity(0.5)
                  : Colors.green.withOpacity(0.5);
              return _buildTimeBlock(
                startTime: start,
                endTime: end,
                totalHeight: height,
                hourHeight: hourHeight,
                color: color,
                label: 'LOG: \n${_formatTimeRange(start, end)}',
                leftOffset: 200,
              );
            }),

            // Draw a line at the current time
            _drawLineAtCurrentTime(day, hourHeight),
          ],
        );
      },
    ),
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
  required DateTime startTime,
  required DateTime endTime,
  required double totalHeight,
  required double hourHeight,
  required Color color,
  required String label,
  double width = 100,
  double leftOffset = 0,
}) {
  final startOffset = startTime.hour * 60 + startTime.minute;
  final endOffset = endTime.hour * 60 + endTime.minute;
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

DateTime _parseTime(String time) {
  final parts = time.split(':');
  return DateTime(2023, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
}
