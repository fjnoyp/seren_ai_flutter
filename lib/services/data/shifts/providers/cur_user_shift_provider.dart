import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/joined_shift_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/shifts_provider.dart';

sealed class CurUserShiftState {
  const CurUserShiftState();
}

class CurUserShiftLoading extends CurUserShiftState {
  const CurUserShiftLoading();
}

class CurUserShiftLoaded extends CurUserShiftState {
  final JoinedShiftModel? shift;
  const CurUserShiftLoaded(this.shift);
}

class CurUserShiftError extends CurUserShiftState {
  final String errorMessage;
  const CurUserShiftError(this.errorMessage);
}

final curUserShiftProvider = NotifierProvider<CurUserShiftNotifier, CurUserShiftState>(() {
  return CurUserShiftNotifier();
});

class CurUserShiftNotifier extends Notifier<CurUserShiftState> {
  @override
  CurUserShiftState build() {
    final shifts = ref.watch(curUserShiftsProvider);
    return shifts.when(
      data: (shifts) => CurUserShiftLoaded(shifts.firstOrNull),
      loading: () => const CurUserShiftLoading(),
      error: (error, stack) => CurUserShiftError(error.toString() + stack.toString()),
    );
  }
}

/*
#0      _$ShiftModelFromJson (package:seren_ai_flutter/services/data/shifts/models/shift_model.g.dart:11:26)
#1      new ShiftModel.fromJson (package:seren_ai_flutter/services/data/shifts/models/shift_model.dart:63:61)
#2      ShiftsRepository.fromJson (package:seren_ai_flutter/services/data/shifts/repositories/shifts_repository.dart:22:25)
#3      BaseRepository.watch.<anonymous closure>.<anonymous closure> (package:seren_ai_flutter/services/data/shifts/repositories/base_repository.dart:19:45)
#4      MappedListIterable.elementAt (dart:_internal/iterable.dart:425:31)
#5      ListIterator.moveNext (dart:_internal/iterable.dart:354:26)
#6      new _GrowableList._ofEfficientLengthIterable (dart:core-patch/growable_array.dart:189:27)
#7      new _GrowableList.of (dart:core-patch/growable_array.dart:150:28)
#8      new List.of (dart:core-patch/array_patch.dart:39:18)
#9      ListIterable.toList (dart:_internal/iterable.dart:224:7)
#10     BaseRepository.watch.<anonymous closure> (package:seren_ai_flutter/services/data/shifts/repositories/base_repository.dart:19:60)
#11     _MapStream._handleData (dart:async/stream_pipe.dart:213:31)
#12     _ForwardingStreamSubscription._handleData (dart:async/stream_pipe.dart:153:13)
#13     _RootZone.runUnaryGuarded (dart:async/zone.dart:1594:10)
#14     _BufferingStreamSubscription._sendData (dart:async/stream_impl.dart:365:11)
#15     _BufferingStreamSubscription._add (dart:async/stream_impl.dart:297:7)
#16     _SyncStreamControllerDispatch._sendData (dart:async/stream_controller.dart:784:19)
#17     _StreamController._add (dart:async/stream_controller.dart:658:7)
#18     _StreamController.add (dart:async/stream_controller.dart:606:5)
#19     _AsyncStarStreamController.add (dart:async-patch/async_patch.dart:76:16)
#20     SqliteQueries.watch (package:sqlite_async/src/sqlite_queries.dart)
<asynchronous suspension>
#21     _ForwardingStreamSubscription._handleData (dart:async/stream_pipe.dart:152:3)
<asynchronous suspension>
*/