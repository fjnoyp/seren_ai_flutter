import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_log_model.dart';

class ShiftLogsResultModel extends AiRequestResultModel {
  final Map<DateTime, List<ShiftLogModel>> shiftLogs;

  ShiftLogsResultModel({
    required this.shiftLogs,
    required super.resultForAi,
    required super.showOnly,
  }) : super(resultType: AiRequestResultType.shiftLogs);

  factory ShiftLogsResultModel.fromJson(Map<String, dynamic> json) {
    return ShiftLogsResultModel(
      shiftLogs: (json['shift_logs'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(
                DateTime.parse(key),
                (value as List)
                    .map((log) => ShiftLogModel.fromJson(log))
                    .toList(),
              )),
      resultForAi: json['result_for_ai'],
      showOnly: json['show_only'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toJson()..addAll({
      'shift_logs': shiftLogs.map((key, value) => MapEntry(
        key.toIso8601String(),
        value.map((log) => log.toJson()).toList(),
      )),
    });
  }
}
