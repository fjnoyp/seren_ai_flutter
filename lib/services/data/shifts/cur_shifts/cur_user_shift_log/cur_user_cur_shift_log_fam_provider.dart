import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_log_model.dart';

final curUserCurShiftLogFamProvider = NotifierProvider.family<CurUserCurShiftLogFamNotifier, ShiftLogModel?, String>(CurUserCurShiftLogFamNotifier.new);

class CurUserCurShiftLogFamNotifier extends FamilyNotifier<ShiftLogModel?, String> {
  @override
  ShiftLogModel? build(String arg) {
    final shiftId = arg;
    
    final curAuthUserState = ref.watch(curAuthUserProvider);
    final curUser = switch (curAuthUserState) {
      LoggedInAuthState() => curAuthUserState.user,
      _ => null,
    };
    if (curUser == null) return null;

    final getUserOpenShiftLogQuery = '''
      SELECT * FROM shift_logs
      WHERE user_id = '${curUser.id}' 
      AND shift_id = '$shiftId' 
      AND clock_out_datetime IS NULL
    ''';

    final db = ref.read(dbProvider);

    final subscription = db.watch(getUserOpenShiftLogQuery).listen((results) {
      final logs = results.map((e) => ShiftLogModel.fromJson(e)).toList();
      state = logs.isNotEmpty ? logs.first : null;
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return null;
  }
}




