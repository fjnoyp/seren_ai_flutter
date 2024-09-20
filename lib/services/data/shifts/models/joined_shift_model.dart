import 'package:seren_ai_flutter/services/data/shifts/models/shift_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_timeframe_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_log_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_override_model.dart';
class JoinedShiftModel {
  final ShiftModel shift;
  final List<ShiftTimeframeModel> timeFrames;
  final List<ShiftLogModel> logs;
  final List<ShiftOverrideModel> overrides;

  JoinedShiftModel({
    required this.shift,
    required this.timeFrames,
    required this.logs,
    required this.overrides,
  });
}