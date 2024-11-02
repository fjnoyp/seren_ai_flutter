import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/utils/date_time_extension.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/cur_shift_dependecy_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_ranges_repository.dart';

final curUserShiftTimeRangesProvider = StreamProvider.autoDispose
    .family<List<DateTimeRange>, ({DateTime day})>((ref, args) {
  return CurShiftDependencyProvider.watchStream(
    ref: ref,
    builder: (userId, joinedShift) => ref.watch(shiftRangesRepositoryProvider).watchActiveRanges(
      shiftId: joinedShift.shift.id,
      userId: userId,
      day: args.day.dateOnlyUTC(),
    ),
  );
});
