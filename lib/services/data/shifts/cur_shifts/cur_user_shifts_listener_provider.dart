// Shift Provider
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_model.dart';

final curUserShiftsListenerProvider = NotifierProvider<CurUserShiftsListenerNotifier, List<ShiftModel>?>(CurUserShiftsListenerNotifier.new);

class CurUserShiftsListenerNotifier extends Notifier<List<ShiftModel>?> {
  @override
  List<ShiftModel>? build() {
    final curAuthUserState = ref.watch(curAuthUserProvider);
    final curUserId = switch (curAuthUserState) {
      LoggedInAuthState() => curAuthUserState.user.id,
      _ => null,
    };

    if (curUserId == null) {
      return null;
    }

    final db = ref.watch(dbProvider);

    final query = '''
      SELECT DISTINCT s.*
      FROM shifts s
      JOIN shift_user_assignments sua ON s.id = sua.shift_id
      WHERE sua.user_id = '$curUserId'
    ''';

    final subscription = db.watch(query).listen((results) {
      List<ShiftModel> items = results.map((e) => ShiftModel.fromJson(e)).toList();
      state = items;
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return null;
  }
}
