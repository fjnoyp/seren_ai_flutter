import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_override_model.dart';

// Overrides Provider
final curUserShiftOverridesFamListenerProvider = NotifierProvider.family<
    CurUserShiftOverridesFamListenerNotifier,
    List<ShiftOverrideModel>?,
    ({
      String shiftId,
      DateTime day
    })>(CurUserShiftOverridesFamListenerNotifier.new);

class CurUserShiftOverridesFamListenerNotifier extends FamilyNotifier<
    List<ShiftOverrideModel>?, ({String shiftId, DateTime day})> {
  @override
  List<ShiftOverrideModel>? build(({String shiftId, DateTime day}) args) {
    final curAuthUserState = ref.read(curAuthStateProvider);
    final curUserId = switch (curAuthUserState) {
      LoggedInAuthState() => curAuthUserState.user.id,
      _ => null,
    };

    if (curUserId == null) {
      return null;
    }

    final db = ref.watch(dbProvider);
    final dayStart = DateTime(args.day.year, args.day.month, args.day.day);

    final query = '''
      SELECT * FROM shift_overrides 
      WHERE shift_id = '${args.shiftId}'
        AND (user_id = '$curUserId' OR user_id IS NULL)
        AND DATE(start_datetime) = DATE('${dayStart.toIso8601String()}')
        OR DATE(end_datetime) = DATE('${dayStart.toIso8601String()}')
    ''';

    final subscription = db.watch(query).listen((results) {
      List<ShiftOverrideModel> items =
          results.map((e) => ShiftOverrideModel.fromJson(e)).toList();
      state = items;
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return null;
  }
}
