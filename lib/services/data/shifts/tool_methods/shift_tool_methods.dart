import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_info_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/ai_request_executor.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/error_request_result_model.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_log_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/cur_shift_state_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/open_shift_log_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/shift_logs_service_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_logs_repository.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_time_ranges_repository.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_assignments_result_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_clock_in_out_result_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_log_results_model.dart';





class ShiftToolMethods {
  ({String userId, String shiftId})? _getAuthAndShiftInfo(Ref ref) {
    final curAuthState = ref.read(curUserProvider);
    final curShiftState = ref.watch(curShiftStateProvider);

    if (curAuthState.value == null) {
      return null;
    }

    return curShiftState.when(
      loading: () => null,
      error: (error, stackTrace) => null,
      data: (joinedShift) {
        if (joinedShift == null) {
          return null;
        }
        return (
          userId: curAuthState.value!.id,
          shiftId: joinedShift.shift.id,
        );
      },
    );
  }

  AiRequestResultModel handleNoAuthOrShiftInfo({AiInfoRequestModel? infoRequest}) {
    return ErrorRequestResultModel(resultForAi: 'No auth or shift info', showOnly: true);
  }

  // Future<AiRequestResultModel> getCurrentShiftInfo(
  //     {required Ref ref, required AiInfoRequestModel infoRequest}) async {
  //   final info = _getAuthAndShiftInfo(ref);
  //   if (info == null) return handleNoAuthOrShiftInfo(infoRequest: infoRequest);

  //   final timeRanges =
  //       await ref.read(shiftTimeRangesRepositoryProvider).getActiveRanges(
  //             shiftId: info.shiftId,
  //             userId: info.userId,
  //             day: DateTime.now().toUtc(),
  //           );

  //   if (timeRanges.isEmpty) {
  //     return ShiftInfoResultModel(
  //       activeShiftRanges: timeRanges,
  //       message: 'No Shifts Today',
  //       showOnly: infoRequest.showOnly,
  //     );
  //   }

  //   return ShiftInfoResultModel(
  //     activeShiftRanges: timeRanges,
  //     message: 'Current shift time ranges: ${timeRanges.map((range) => '${range.start.toLocal()} - ${range.end.toLocal()}').join('\n')}',
  //     showOnly: infoRequest.showOnly,
  //   );
  // }

  Future<AiRequestResultModel> getShiftAssignments({required Ref ref, required ShiftAssignmentsRequestModel infoRequest}) async {
    final info = _getAuthAndShiftInfo(ref);
    if (info == null) return handleNoAuthOrShiftInfo();

    // 0 = today, 1 = tomorrow, -1 = yesterday, etc.
    final List<int> dayOffsetsToGet = infoRequest.dayOffsetsToGet;

    // Get current local date
    final DateTime now = DateTime.now();

    final Map<DateTime, List<DateTimeRange>> shiftAssignments = {};

    await Future.wait(dayOffsetsToGet.map((offset) async {
      final DateTime day = now.add(Duration(days: offset));
      final DateTime dayUtc = day.toUtc();

      final timeRangesForDay = await ref.read(shiftTimeRangesRepositoryProvider).getActiveRanges(
            shiftId: info.shiftId,
            userId: info.userId,
            day: dayUtc,
          );

      shiftAssignments[day] = timeRangesForDay;
    }));

    return ShiftAssignmentsResultModel(
      shiftAssignments: shiftAssignments,
      resultForAi: shiftAssignments.isEmpty 
          ? 'No shift assignments in requested range.' 
          : 'Shift assignments: ${shiftAssignments.entries.map((entry) => '${entry.key.toLocal()} - ${entry.value.map((range) => '${range.start.toLocal()} - ${range.end.toLocal()}').join('\n')}').join('\n')}',
      showOnly: infoRequest.showOnly,
    );
  }

  Future<AiRequestResultModel> getShiftLogs({required Ref ref, required ShiftLogsRequestModel infoRequest}) async {
    final info = _getAuthAndShiftInfo(ref);
    if (info == null) return handleNoAuthOrShiftInfo();

    // 0 = today, 1 = tomorrow, -1 = yesterday, etc.
    final List<int> dayOffsetsToGet = infoRequest.dayOffsetsToGet;

    // Get current local date
    final DateTime now = DateTime.now();

    final Map<DateTime, List<ShiftLogModel>> shiftLogs = {};

    await Future.wait(dayOffsetsToGet.map((offset) async {
      final DateTime day = now.add(Duration(days: offset)); 
      final DateTime dayUtc = day.toUtc(); 

      final shiftLogsForDay = await ref.read(shiftLogsRepositoryProvider).getUserShiftLogsForDay(
        shiftId: info.shiftId,
        userId: info.userId,
        day: dayUtc,
      );

      shiftLogs[day] = shiftLogsForDay;
    }));
    return ShiftLogsResultModel(
      shiftLogs: shiftLogs,
      resultForAi: shiftLogs.isEmpty 
          ? 'No shift logs in requested range.' 
          : 'Shift logs: ${shiftLogs.entries.map((entry) => '${entry.key.toLocal()} - ${entry.value.map((log) => '${log.clockInDatetime.toLocal()} - ${log.clockOutDatetime?.toLocal() ?? 'ONGOING'}').join('\n')}').join('\n')}',
      showOnly: infoRequest.showOnly,
    );
  }

  Future<AiRequestResultModel> toggleClockInOut({required Ref ref}) async {
    final info = _getAuthAndShiftInfo(ref);
    if (info == null) return handleNoAuthOrShiftInfo();

    // Check if there is an open shift log
    final openShiftLog = await ref.read(shiftLogsRepositoryProvider).getCurrentOpenLog(
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
          showOnly: true,
        );
      }

      return ShiftClockInOutResultModel(
        clockedIn: false,
        resultForAi: 'Successfully clocked out!',
        showOnly: true,
      );
    } else {
      // If there is no open shift log, clock in
      final result = await ref
          .read(shiftLogServiceProvider)
          .clockIn(userId: info.userId, shiftId: info.shiftId);

      if (result.error != null) {
        return ErrorRequestResultModel(
          resultForAi: 'Failed to clock in: ${result.error!}',
          showOnly: true,
        );
      }

      return ShiftClockInOutResultModel(
        clockedIn: true,
        resultForAi: 'Successfully clocked in!',
        showOnly: true,
      );
    }
  }
}
