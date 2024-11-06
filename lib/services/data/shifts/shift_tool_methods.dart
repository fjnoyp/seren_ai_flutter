import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/ai_info_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/ai_request_executor.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/cur_shift_state_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/shift_logs_service_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_time_ranges_repository.dart';

class ShiftInfoResult extends AiRequestResult {
  final List<DateTimeRange> activeShiftRanges;
  ShiftInfoResult({
    required this.activeShiftRanges,
    required super.message,
    required super.showOnly,
  });
}

class ShiftClockInOutResult extends AiRequestResult {
  final bool hasError;
  final bool clockedIn;
  ShiftClockInOutResult({
    required this.clockedIn,
    this.hasError = false,
    required super.message,
    required super.showOnly,
  });
}

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

  AiRequestResult handleNoAuthOrShiftInfo({AiInfoRequestModel? infoRequest}) {
    return AiRequestResult(
      message: 'Not authenticated or no active shift',
      showOnly: infoRequest?.showOnly ?? true,
    );
  }

  Future<AiRequestResult> getCurrentShiftInfo(
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
      activeShiftRanges: timeRanges,
      message:
          'Current shift time ranges: ${timeRanges.map((range) => '${range.start.toLocal()} - ${range.end.toLocal()}').join('\n')}',
      showOnly: infoRequest.showOnly,
    );
  }

  Future<AiRequestResult> clockIn({required Ref ref}) async {
    final info = _getAuthAndShiftInfo(ref);
    if (info == null) return handleNoAuthOrShiftInfo();

    final result = await ref
        .read(shiftLogServiceProvider)
        .clockIn(userId: info.userId, shiftId: info.shiftId);

    if (result.error != null) {
      return ShiftClockInOutResult(
        clockedIn: false,
        hasError: true,
        message: result.error!,
        showOnly: true,
      );
    }

    return ShiftClockInOutResult(
      clockedIn: true,
      message: 'Successfully clocked in!',
      showOnly: true,
    );
  }

  Future<AiRequestResult> clockOut({required Ref ref}) async {
    final info = _getAuthAndShiftInfo(ref);
    if (info == null) return handleNoAuthOrShiftInfo();

    final result = await ref
        .read(shiftLogServiceProvider)
        .clockOut(userId: info.userId, shiftId: info.shiftId);

    if (result.error != null) {
      return ShiftClockInOutResult(
        clockedIn: false,
        hasError: true,
        message: result.error!,
        showOnly: true,
      );
    }

    return ShiftClockInOutResult(
      clockedIn: false,
      message: 'Successfully clocked out!',
      showOnly: true,
    );
  }
}
