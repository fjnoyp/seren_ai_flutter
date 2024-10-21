import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_log_model.dart';

// Logs Provider
final curUserShiftLogsFamListenerProvider = NotifierProvider.family<
    CurUserShiftLogsFamListenerNotifier,
    List<ShiftLogModel>?,
    ({String shiftId, DateTime day})>(CurUserShiftLogsFamListenerNotifier.new);

class CurUserShiftLogsFamListenerNotifier extends FamilyNotifier<
    List<ShiftLogModel>?, ({String shiftId, DateTime day})> {
  @override
  List<ShiftLogModel>? build(({String shiftId, DateTime day}) args) {
    final curAuthUserState = ref.read(curAuthStateProvider);
    final curUser = switch (curAuthUserState) {
      LoggedInAuthState() => curAuthUserState.user,
      _ => null,
    };
    final curUserId = curUser?.id;

    if (curUserId == null) {
      return null;
    }

    final db = ref.watch(dbProvider);
    final dayStart = DateTime(args.day.year, args.day.month, args.day.day);

    final query = '''
      SELECT * FROM shift_logs 
      WHERE shift_id = '${args.shiftId}'
        AND user_id = '$curUserId'
        AND (DATE(clock_in_datetime) = DATE('${dayStart.toIso8601String()}')
        OR DATE(clock_out_datetime) = DATE('${dayStart.toIso8601String()}'))
    ''';

    final subscription = db.watch(query).listen((results) {
      List<ShiftLogModel> items =
          results.map((e) => ShiftLogModel.fromJson(e)).toList();
      state = items;
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return null;
  }
}
