import 'package:seren_ai_flutter/services/data/common/base_table_db.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_log_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_logs_repository.dart';

class ShiftLogService extends BaseTableDb<ShiftLogModel> {
  final ShiftLogsRepository _repository;

  ShiftLogService(this._repository)
      : super(
          db: _repository.db,
          tableName: 'shift_logs',
          fromJson: ShiftLogModel.fromJson,
          toJson: (item) => item.toJson(),
        );

  Future<({String? error})> clockIn(
      {required String userId, required String shiftId}) async {
    try {
      final curLog = await _repository.getCurrentOpenLog(
        shiftId: shiftId,
        userId: userId,
      );
      if (curLog != null) {
        return (error: 'Shift log already exists');
      }

      final newLog = ShiftLogModel(
        shiftId: shiftId,
        userId: userId,
        clockInDatetime: DateTime.now().toUtc(),
        isBreak: false,
      );

      await insertItem(newLog);
      return (error: null);
    } catch (e) {
      return (error: e.toString());
    }
  }

  Future<({String? error})> clockOut(
      {required String userId, required String shiftId}) async {
    try {
      final curLog = await _repository.getCurrentOpenLog(
        shiftId: shiftId,
        userId: userId,
      );
      if (curLog == null) {
        return (error: 'No shift log found');
      }

      final clockOutTime = DateTime.now().toUtc();
      await updateItem(curLog.copyWith(clockOutDatetime: clockOutTime));
      return (error: null);
    } catch (e) {
      return (error: e.toString());
    }
  }

  Future<({String? error})> deleteLog({
    required ShiftLogModel log,
    required String modificationReason,
  }) async {
    try {
      if (modificationReason.isEmpty) {
        return (error: 'Deletion reason is required');
      }
      await updateItem(
        log.copyWith(isDeleted: true, modificationReason: modificationReason),
      );
      return (error: null);
    } catch (e) {
      return (error: e.toString());
    }
  }

  Future<({String? error})> editLog({
    required ShiftLogModel log,
    required String modificationReason,
    DateTime? newClockInTime,
    DateTime? newClockOutTime,
  }) async {
    if (modificationReason.isEmpty) {
      return (error: 'Modification reason is required');
    }
    try {
      final newLog = ShiftLogModel(
        userId: log.userId,
        shiftId: log.shiftId,
        clockInDatetime: newClockInTime ?? log.clockInDatetime,
        clockOutDatetime: newClockOutTime ?? log.clockOutDatetime,
        isBreak: log.isBreak,
        modificationReason: modificationReason,
        shiftLogParentId: log.id,
      );
      await updateItem(log.copyWith(isDeleted: true));
      await insertItem(newLog);
      return (error: null);
    } catch (e) {
      return (error: e.toString());
    }
  }
}
