import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/cur_shifts/cur_user_shift_log/cur_user_cur_shift_log_fam_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_log_model.dart';

final curUserCurShiftLogNotifierProvider = Provider.family<CurUserCurShiftLogNotifier, String>((ref, shiftId) {
  return CurUserCurShiftLogNotifier(ref: ref, shiftId: shiftId);
});

class CurUserCurShiftLogNotifier {
  final Ref ref;
  final String shiftId;

  CurUserCurShiftLogNotifier({required this.ref, required this.shiftId});

  Future<void> clockIn() async {
    final db = ref.read(dbProvider);
    final curUser = ref.read(curAuthUserProvider);
    if (curUser == null) throw Exception('No user found');

    final curLog = ref.read(curUserCurShiftLogFamProvider(shiftId)); 
    if (curLog != null) throw Exception('Shift log already exists');

    final newLog = ShiftLogModel(
      shiftId: shiftId,
      userId: curUser.id,
      clockInDatetime: DateTime.now().toUtc(),
      isBreak: false,
    );
    await db.execute(
      'INSERT INTO shift_logs (id, shift_id, user_id, clock_in_datetime, is_break) VALUES (?, ?, ?, ?, ?)',
      [newLog.id, newLog.shiftId, newLog.userId, newLog.clockInDatetime.toIso8601String(), newLog.isBreak ? 1 : 0]
    );
  }

  Future<void> clockOut() async {
    final db = ref.read(dbProvider);
    final curLog = ref.read(curUserCurShiftLogFamProvider(shiftId)); 

    if (curLog != null) {
      final clockOutTime = DateTime.now().toUtc();
      await db.execute(
        'UPDATE shift_logs SET clock_out_datetime = ? WHERE id = ?',
        [clockOutTime.toIso8601String(), curLog.id]
      );
    }
    else{
      throw Exception('No shift log found');
    }
  }
}
