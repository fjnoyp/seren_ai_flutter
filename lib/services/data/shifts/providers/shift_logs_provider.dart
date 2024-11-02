import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/utils/date_time_extension.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_log_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/cur_shift_dependecy_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_logs_repository.dart';

final curUserShiftLogsProvider = StreamProvider.autoDispose.family<List<ShiftLogModel>, ({DateTime day})>((ref, args) {
  return CurShiftDependencyProvider.watchStream<List<ShiftLogModel>>(
    ref: ref,
    builder: (userId, joinedShift) {
      return ref.watch(shiftLogsRepositoryProvider).watchUserShiftLogsForDay(
        shiftId: joinedShift.shift.id,
        userId: userId,
        day: args.day.dateOnlyUTC(),
      );
    },
  );
});
