import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/base_table_db.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_log_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_logs_repository.dart';


class ShiftLogService extends BaseTableDb<ShiftLogModel> {
  final ShiftLogsRepository _repository;
  final Ref ref;

  ShiftLogService(this.ref)
      : _repository = ref.read(shiftLogsRepositoryProvider),
        super(
          db: ref.read(shiftLogsRepositoryProvider).db,
          tableName: 'shift_logs',
          fromJson: ShiftLogModel.fromJson,
          toJson: (item) => item.toJson(),
        );

  Future<void> clockIn(String shiftId) async {
    final curUser = ref.read(curAuthStateProvider.notifier).getCurrentUser();
    if (curUser == null) throw Exception('No user found');

    final curLog = await _repository.getCurrentOpenLog(
      shiftId: shiftId,
      userId: curUser.id,
    );
    if (curLog != null) throw Exception('Shift log already exists');

    final newLog = ShiftLogModel(
      shiftId: shiftId,
      userId: curUser.id,
      clockInDatetime: DateTime.now().toUtc(),
      isBreak: false,
    );

    await insertItem(newLog);
  }

  Future<void> clockOut(String shiftId) async {
    final curUser = ref.read(curAuthStateProvider.notifier).getCurrentUser();
    if (curUser == null) throw Exception('No user found');

    final curLog = await _repository.getCurrentOpenLog(
      shiftId: shiftId,
      userId: curUser.id,
    );
    if (curLog == null) throw Exception('No shift log found');

    final clockOutTime = DateTime.now().toUtc();
    await updateItem(curLog.copyWith(clockOutDatetime: clockOutTime));
  }
}