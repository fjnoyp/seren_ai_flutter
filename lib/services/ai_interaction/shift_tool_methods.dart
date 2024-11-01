import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_tool_response_executor.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_tool_response_model.dart';

import 'package:seren_ai_flutter/services/data/shifts/z_graveyard/cur_shifts/cur_user_active_shift_ranges_fam_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/z_graveyard/cur_shifts/cur_user_joined_shift_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/z_graveyard/cur_shifts/cur_user_shift_log/cur_user_cur_shift_log_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/z_graveyard/cur_shifts/shift_day_fam_listener_providers/cur_user_shift_logs_fam_listener_provider.dart';

class ShiftInfoResult extends ToolResponseResult {
  final List<DateTimeRange> activeShiftRanges;  
  ShiftInfoResult({    
    required this.activeShiftRanges,
    required super.message,
    required super.showOnly,
  });
}

class ShiftToolMethods {

  Future<ToolResponseResult> getCurrentShiftInfo(
      {required Ref ref, required AiInfoRequestModel infoRequest}) async {
    // TODO p1: use current shift provider and return information to ai

    final curShiftState = ref.read(curUserJoinedShiftProvider);
    if (curShiftState is CurUserJoinedShiftLoaded) {
      final joinedShift = curShiftState.joinedShift;

      if (joinedShift != null) {
        final activeShiftRanges = ref.read(curUserActiveShiftRangesFamProvider(
            (shiftId: joinedShift.shift.id, day: DateTime.now().toUtc())));

        // TODO p1: determine return format
        final message =
            "Current shift: ${joinedShift.shift.name}\n${activeShiftRanges.map((range) => '${range.start.toLocal()} - ${range.end.toLocal()}').join('\n')}";
        return ShiftInfoResult(
          activeShiftRanges: activeShiftRanges,
          message: message,
          showOnly: infoRequest.showOnly,
        );
      } else {
        return ToolResponseResult(
          message: 'No active shift found!',
          showOnly: infoRequest.showOnly,
        );
      }

    } else if (curShiftState is CurUserJoinedShiftLoading) {
      return ToolResponseResult(
        message: 'Shifts still loading, please try again later.',
        showOnly: infoRequest.showOnly,
      );
    } else {
      throw Exception('Unknown cur shift state: ${curShiftState.runtimeType}');
    }
  }

  Future<ToolResponseResult> clockIn({required Ref ref}) async {
    final curShiftState = ref.read(curUserJoinedShiftProvider);
    if (curShiftState is CurUserJoinedShiftLoaded) {
      final joinedShift = curShiftState.joinedShift;
      
      if (joinedShift != null) {
        final today = DateTime.now().toUtc();
        final logs = ref.read(curUserShiftLogsFamListenerProvider((
          shiftId: joinedShift.shift.id,
          day: today,
        )));

        if (logs != null && logs.any((log) => log.clockOutDatetime == null)) {
          return ToolResponseResult(
            message: 'You are already clocked in!',
            showOnly: true,
          );
        }

        await ref.read(curUserCurShiftLogNotifierProvider(joinedShift.shift.id)).clockIn();
        return ToolResponseResult(
          message: 'Successfully clocked in!',
          showOnly: true,
        );
      } else {
        return ToolResponseResult(
          message: 'No active shift found to clock into!',
          showOnly: true,
        );
      }
    } else {
      throw Exception('Cannot clock in - shift state is ${curShiftState.runtimeType}');
    }
  }

  Future<ToolResponseResult> clockOut({required Ref ref}) async {
    final curShiftState = ref.read(curUserJoinedShiftProvider);
    if (curShiftState is CurUserJoinedShiftLoaded) {
      final joinedShift = curShiftState.joinedShift;
      
      if (joinedShift != null) {
        final today = DateTime.now().toUtc();
        final logs = ref.read(curUserShiftLogsFamListenerProvider((
          shiftId: joinedShift.shift.id,
          day: today,
        )));

        if (logs == null || !logs.any((log) => log.clockOutDatetime == null)) {
          return ToolResponseResult(
            message: 'You are not currently clocked in!',
            showOnly: true,
          );
        }

        await ref.read(curUserCurShiftLogNotifierProvider(joinedShift.shift.id)).clockOut();
        return ToolResponseResult(
          message: 'Successfully clocked out!',
          showOnly: true,
        );
      } else {
        return ToolResponseResult(
          message: 'No active shift found to clock out of!',
          showOnly: true,
        );
      }
    } else {
      throw Exception('Cannot clock out - shift state is ${curShiftState.runtimeType}');
    }
  }
}
