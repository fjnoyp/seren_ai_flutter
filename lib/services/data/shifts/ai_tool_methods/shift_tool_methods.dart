import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/utils/date_time_extension.dart';
import 'package:seren_ai_flutter/common/utils/date_time_range_extension.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/models/results/error_request_result_model.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shifts_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/ai_tool_methods/ai_date_parser.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_log_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/cur_shift_state_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/shift_logs_service_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_logs_repository.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_time_ranges_repository.dart';
import 'package:seren_ai_flutter/services/data/shifts/ai_tool_methods/models/shift_assignments_result_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/ai_tool_methods/models/shift_clock_in_out_result_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/ai_tool_methods/models/shift_log_results_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/ai_tool_methods/models/shift_request_models.dart';
import 'package:seren_ai_flutter/services/data/shifts/ai_tool_methods/models/current_shift_info_result_model.dart';

/*
Method executors for: 

AiInfoRequestType.shiftAssignments
AiInfoRequestType.shiftLogs

AiActionRequestType.toggleClockInOrOut
*/
class ShiftToolMethods {
  // TODO p2: use showToUser to show in UI if necessary
  Future<AiRequestResultModel> getShiftAssignments(
      {required Ref ref,
      required ShiftAssignmentsRequestModel infoRequest,
      bool allowToolUiActions = true}) async {
    final info = _getAuthAndShiftInfo(ref);
    if (info == null) return _handleNoAuthOrShiftInfo();

    final List<String> daysToGet = infoRequest.daysToGet;
    final List<DateTime> parsedDays = AiDateParser.parseDateList(daysToGet);

    final Map<DateTime, List<DateTimeRange>> shiftAssignments = {};

    await Future.wait(parsedDays.map((day) async {
      final timeRangesForDay =
          await ref.read(shiftTimeRangesRepositoryProvider).getActiveRanges(
                shiftId: info.shiftId,
                userId: info.userId,
                day: day,
              );
      shiftAssignments[day] = timeRangesForDay;
    }));

    Duration totalDuration = Duration.zero;
    for (final ranges in shiftAssignments.values) {
      for (final range in ranges) {
        totalDuration += range.duration;
      }
    }
    final totalDurationStr =
        'Total assigned hours: ${totalDuration.inHours}h ${totalDuration.inMinutes % 60}m';

    return ShiftAssignmentsResultModel(
      shiftAssignments: shiftAssignments,
      totalShiftMinutes: totalDuration.inMinutes,
      resultForAi: shiftAssignments.isEmpty
          ? 'No shift assignments in requested range.'
          : 'Shift assignments: ${shiftAssignments.entries.map((entry) => '${entry.key.toLocal().toSimpleDateString()} - ${entry.value.map((range) => range.getReadableTimeOnly()).join('\n')}').join('\n')}\n$totalDurationStr',
    );
  }

  // TODO p2: use showToUser to show in UI if necessary
  Future<AiRequestResultModel> getShiftLogs(
      {required Ref ref,
      required ShiftLogsRequestModel infoRequest,
      bool allowToolUiActions = true}) async {
    final info = _getAuthAndShiftInfo(ref);
    if (info == null) return _handleNoAuthOrShiftInfo();

    final List<String> daysToGet = infoRequest.daysToGet;
    final List<DateTime> parsedDays = AiDateParser.parseDateList(daysToGet);

    final Map<DateTime, List<ShiftLogModel>> shiftLogs = {};

    await Future.wait(parsedDays.map((day) async {
      final shiftLogsForDay =
          await ref.read(shiftLogsRepositoryProvider).getUserShiftLogsForDay(
                shiftId: info.shiftId,
                userId: info.userId,
                day: day,
              );
      shiftLogs[day] = shiftLogsForDay;
    }));

    Duration? curShiftDuration;
    Duration totalLogDuration = Duration.zero;
    // If there is open shift log, calculate duration so far
    for (final logs in shiftLogs.values) {
      for (final log in logs) {
        if (log.clockOutDatetime == null) {
          curShiftDuration =
              DateTime.now().toUtc().difference(log.clockInDatetime.toUtc());
        } else {
          totalLogDuration +=
              log.clockOutDatetime!.difference(log.clockInDatetime);
        }
      }
    }

    final totalDurationStr =
        'Total logged hours: ${totalLogDuration.inHours}h ${totalLogDuration.inMinutes % 60}m';
    final curDurationStr = curShiftDuration != null
        ? 'Current shift duration: ${curShiftDuration.inHours}h ${curShiftDuration.inMinutes % 60}m'
        : '';

    return ShiftLogsResultModel(
      shiftLogs: shiftLogs,
      curShiftMinutes: curShiftDuration?.inMinutes,
      totalLogMinutes: totalLogDuration.inMinutes,
      resultForAi: shiftLogs.isEmpty
          ? 'No shift logs in requested range.'
          : 'Shift logs: ${shiftLogs.entries.map((entry) => '${entry.key.toLocal().toSimpleDateString()} - ${entry.value.map((log) => '${log.clockInDatetime.toLocal().toSimpleTimeString()} - ${log.clockOutDatetime?.toLocal().toSimpleTimeString() ?? 'ONGOING'}').join('\n')}').join('\n')}\n$totalDurationStr${curShiftDuration != null ? '\n$curDurationStr' : ''}',
    );
  }

  Future<AiRequestResultModel> getCurrentShiftInfo(
      {required Ref ref,
      required CurrentShiftInfoRequestModel infoRequest}) async {
    final info = _getAuthAndShiftInfo(ref);
    if (info == null) return _handleNoAuthOrShiftInfo();

    // Get current open shift log if any
    final openShiftLog =
        await ref.read(shiftLogsRepositoryProvider).getCurrentOpenLog(
              shiftId: info.shiftId,
              userId: info.userId,
            );

    // Get today's shift assignments
    final today = DateTime.now().toUtc();
    final todayAssignments =
        await ref.read(shiftTimeRangesRepositoryProvider).getActiveRanges(
              shiftId: info.shiftId,
              userId: info.userId,
              day: today,
            );

    // Get shift details
    final shift =
        await ref.read(shiftsRepositoryProvider).getById(info.shiftId);

    // Format the response
    String resultForAi = 'Current shift information:\n';

    // Add shift name/details
    if (shift != null) {
      resultForAi += 'Shift: ${shift.name}\n';
    }

    // Add clock in status
    if (openShiftLog != null) {
      final duration =
          DateTime.now().toUtc().difference(openShiftLog.clockInDatetime);
      resultForAi += 'Status: Clocked in\n';
      resultForAi +=
          'Clocked in at: ${openShiftLog.clockInDatetime.toLocal().toSimpleTimeString()}\n';
      resultForAi +=
          'Current duration: ${duration.inHours}h ${duration.inMinutes % 60}m\n';
    } else {
      resultForAi += 'Status: Not clocked in\n';
    }

    // Add today's assignments
    if (todayAssignments.isNotEmpty) {
      resultForAi += 'Today\'s assignments:\n';
      for (final range in todayAssignments) {
        resultForAi +=
            '- ${range.start.toLocal().toSimpleTimeString()} to ${range.end.toLocal().toSimpleTimeString()}\n';
      }
    } else {
      resultForAi += 'No assignments scheduled for today.\n';
    }

    return CurrentShiftInfoResultModel(
      isUserClockedIn: openShiftLog != null,
      clockInTime: openShiftLog?.clockInDatetime,
      curShiftDurationMinutes: openShiftLog != null
          ? DateTime.now()
              .toUtc()
              .difference(openShiftLog.clockInDatetime)
              .inMinutes
          : null,
      todayAssignments: todayAssignments,
      shift: shift,
      resultForAi: resultForAi,
    );
  }

  Future<AiRequestResultModel> toggleClockInOut({required Ref ref}) async {
    final info = _getAuthAndShiftInfo(ref);
    if (info == null) return _handleNoAuthOrShiftInfo();

    // Check if there is an open shift log
    final openShiftLog =
        await ref.read(shiftLogsRepositoryProvider).getCurrentOpenLog(
              shiftId: info.shiftId,
              userId: info.userId,
            );

    if (openShiftLog != null) {
      // If there is an open shift log, clock out
      final result = await ref
          .read(shiftLogServiceProvider)
          .clockOut(userId: info.userId, shiftId: info.shiftId);

      if (result.error != null) {
        return ErrorRequestResultModel(
          resultForAi: 'Failed to clock out: ${result.error!}',
        );
      }

      return ShiftClockInOutResultModel(
        clockedIn: false,
        resultForAi: 'Successfully clocked out!',
      );
    } else {
      // If there is no open shift log, clock in
      final result = await ref
          .read(shiftLogServiceProvider)
          .clockIn(userId: info.userId, shiftId: info.shiftId);

      if (result.error != null) {
        return ErrorRequestResultModel(
          resultForAi: 'Failed to clock in: ${result.error!}',
        );
      }

      return ShiftClockInOutResultModel(
        clockedIn: true,
        resultForAi: 'Successfully clocked in!',
      );
    }
  }

  ({String userId, String shiftId})? _getAuthAndShiftInfo(Ref ref) {
    final curAuthState = ref.read(curUserProvider);
    final curShiftState = ref.watch(curShiftStateProvider);

    if (curAuthState.value == null) {
      return null;
    }

    return curShiftState.when(
      loading: () => null,
      error: (error, stackTrace) => null,
      data: (shift) {
        if (shift == null) {
          return null;
        }
        return (
          userId: curAuthState.value!.id,
          shiftId: shift.id,
        );
      },
    );
  }

  AiRequestResultModel _handleNoAuthOrShiftInfo() {
    return ErrorRequestResultModel(resultForAi: 'No auth or shift info');
  }
}
