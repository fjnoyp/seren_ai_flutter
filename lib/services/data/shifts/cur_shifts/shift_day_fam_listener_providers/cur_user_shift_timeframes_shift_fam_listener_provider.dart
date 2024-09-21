// Shift Provider
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_timeframe_model.dart';

// Timeframes Provider
final curUserShiftTimeframesFamListenerProvider = NotifierProvider.family<CurUserShiftTimeframesFamListenerNotifier, List<ShiftTimeframeModel>?, String>(CurUserShiftTimeframesFamListenerNotifier.new);

class CurUserShiftTimeframesFamListenerNotifier extends FamilyNotifier<List<ShiftTimeframeModel>?, String> {
  @override
  List<ShiftTimeframeModel>? build(String shiftId) {
    final db = ref.watch(dbProvider);

    final query = '''
      SELECT * FROM shift_timeframes 
      WHERE shift_id = '$shiftId'
    ''';

    final subscription = db.watch(query).listen((results) {
      List<ShiftTimeframeModel> items = results.map((e) => ShiftTimeframeModel.fromJson(e)).toList();
      state = items;
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return null;
  }
}
