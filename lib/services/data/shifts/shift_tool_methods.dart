import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/utils/date_time_extension.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_tool_response_executor.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_tool_response_model.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/cur_shift_state_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/shift_logs_service_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/shift_time_ranges_providers.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_time_ranges_repository.dart';

class ShiftInfoResult extends ToolResponseResult {
  final List<DateTimeRange> activeShiftRanges;
  ShiftInfoResult({
    required this.activeShiftRanges,
    required super.message,
    required super.showOnly,
  });
}

class ShiftToolMethods {



  ({String userId, String shiftId})? _getAuthAndShiftInfo(Ref ref) {
    final curAuthState = ref.read(curAuthStateProvider);
    final curShiftState = ref.read(curShiftStateProvider);

    if (curAuthState is! LoggedInAuthState) {
      return null;
    }

    if (curShiftState is! CurShiftLoaded) {
      return null;
    }

    final joinedShift = curShiftState.joinedShift;
    if (joinedShift == null) {
      return null;
    }

    return (userId: curAuthState.user.id, shiftId: joinedShift.shift.id);
  }

  ToolResponseResult handleNoAuthOrShiftInfo({AiInfoRequestModel? infoRequest}) {
    return ToolResponseResult(
      message: 'Not authenticated or no active shift',
      showOnly: infoRequest?.showOnly ?? true,
    );
  }

  Future<ToolResponseResult> getCurrentShiftInfo(
      {required Ref ref, required AiInfoRequestModel infoRequest}) async {
    final info = _getAuthAndShiftInfo(ref);
    if (info == null) return handleNoAuthOrShiftInfo(infoRequest: infoRequest);

    final timeRanges =
        await ref.read(shiftTimeRangesRepositoryProvider).getActiveRanges(
              shiftId: info.shiftId,
              userId: info.userId,
              day: DateTime.now().toUtc(),
            );

    return ShiftInfoResult(
      activeShiftRanges: timeRanges ?? [],
      message:
          'Current shift time ranges: ${timeRanges.map((range) => '${range.start.toLocal()} - ${range.end.toLocal()}').join('\n')}',
      showOnly: infoRequest.showOnly,
    );
  }

  Future<ToolResponseResult> clockIn({required Ref ref}) async {
    final info = _getAuthAndShiftInfo(ref);
    if (info == null) return handleNoAuthOrShiftInfo();

    final result = await ref.read(shiftLogServiceProvider).clockIn(userId: info.userId, shiftId: info.shiftId);

    if (result.error != null) {
      return ToolResponseResult(
        message: result.error!,
        showOnly: true,
      );
    }

    return ToolResponseResult(
      message: 'Successfully clocked in!',
      showOnly: true,
    );

  }

  Future<ToolResponseResult> clockOut({required Ref ref}) async {
    final info = _getAuthAndShiftInfo(ref);
    if (info == null) return handleNoAuthOrShiftInfo();

    final result = await ref.read(shiftLogServiceProvider).clockOut(userId: info.userId, shiftId: info.shiftId);

    if (result.error != null) {
      return ToolResponseResult(
        message: result.error!,
        showOnly: true,
      );
    }

    return ToolResponseResult(
      message: 'Successfully clocked out!',
      showOnly: true,
    );
  }
}
