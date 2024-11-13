import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_info_request_model.dart';

// Dart class representation of python shift_tool.py generated requests 

class ShiftAssignmentsRequestModel extends AiInfoRequestModel {
  final List<int> dayOffsetsToGet;

  ShiftAssignmentsRequestModel({
    required this.dayOffsetsToGet,
    super.showOnly = true,
    super.args,
  }) : super(infoRequestType: AiInfoRequestType.shiftAssignments);

  static ShiftAssignmentsRequestModel fromJson(Map<String, dynamic> json) {
    return ShiftAssignmentsRequestModel(
      args: json['args'],
      dayOffsetsToGet: json['args']['day_offsets_to_get'].cast<int>(),
      showOnly: json['show_only'] ?? true,
    );
  }
}

class ShiftLogsRequestModel extends AiInfoRequestModel {
  final List<int> dayOffsetsToGet;

  ShiftLogsRequestModel({
    required this.dayOffsetsToGet,
    super.showOnly = true,
    super.args,
  }) : super(infoRequestType: AiInfoRequestType.shiftLogs);

  static ShiftLogsRequestModel fromJson(Map<String, dynamic> json) {
    return ShiftLogsRequestModel(
      args: json['args'],
      dayOffsetsToGet: json['args']['day_offsets_to_get'].cast<int>(),
      showOnly: json['show_only'] ?? true,
    );
  }
}
