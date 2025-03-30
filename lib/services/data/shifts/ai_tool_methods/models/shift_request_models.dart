import 'package:seren_ai_flutter/services/ai/ai_request/models/requests/ai_info_request_model.dart';

// Dart class representation of python shift_tool.py generated requests

class ShiftAssignmentsRequestModel extends AiInfoRequestModel {
  final List<String> daysToGet;

  ShiftAssignmentsRequestModel({
    required this.daysToGet,
    super.showUI = true,
    super.args,
  }) : super(infoRequestType: AiInfoRequestType.shiftAssignments);

  static ShiftAssignmentsRequestModel fromJson(Map<String, dynamic> json) {
    return ShiftAssignmentsRequestModel(
      args: json['args'],
      daysToGet:
          (json['args']['days_to_get'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

class ShiftLogsRequestModel extends AiInfoRequestModel {
  final List<String> daysToGet;

  ShiftLogsRequestModel({
    required this.daysToGet,
    super.showUI = true,
    super.args,
  }) : super(infoRequestType: AiInfoRequestType.shiftLogs);

  static ShiftLogsRequestModel fromJson(Map<String, dynamic> json) {
    return ShiftLogsRequestModel(
      args: json['args'],
      daysToGet:
          (json['args']['days_to_get'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}
