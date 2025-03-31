import 'package:seren_ai_flutter/services/ai/ai_request/models/requests/ai_info_request_model.dart';

// Dart class representation of python shift_tool.py generated requests

class ShiftAssignmentsRequestModel extends AiInfoRequestModel {
  final List<String> daysToGet;
  final bool showToUser;

  ShiftAssignmentsRequestModel({
    required this.daysToGet,
    this.showToUser = true,
    super.args,
  }) : super(infoRequestType: AiInfoRequestType.shiftAssignments);

  static ShiftAssignmentsRequestModel fromJson(Map<String, dynamic> json) {
    return ShiftAssignmentsRequestModel(
      args: json['args'],
      daysToGet:
          (json['args']['days_to_get'] as List<dynamic>?)?.cast<String>() ?? [],
      showToUser: json['args']['show_to_user'] ?? true,
    );
  }
}

class ShiftLogsRequestModel extends AiInfoRequestModel {
  final List<String> daysToGet;
  final bool showToUser;

  ShiftLogsRequestModel({
    required this.daysToGet,
    this.showToUser = true,
    super.args,
  }) : super(infoRequestType: AiInfoRequestType.shiftLogs);

  static ShiftLogsRequestModel fromJson(Map<String, dynamic> json) {
    return ShiftLogsRequestModel(
      args: json['args'],
      daysToGet:
          (json['args']['days_to_get'] as List<dynamic>?)?.cast<String>() ?? [],
      showToUser: json['args']['show_to_user'] ?? true,
    );
  }
}

class CurrentShiftInfoRequestModel extends AiInfoRequestModel {
  final bool showToUser;

  CurrentShiftInfoRequestModel({
    this.showToUser = true,
    super.args,
  }) : super(infoRequestType: AiInfoRequestType.currentShiftInfo);

  static CurrentShiftInfoRequestModel fromJson(Map<String, dynamic> json) {
    return CurrentShiftInfoRequestModel(
      args: json['args'],
      showToUser: json['args']['show_to_user'] ?? true,
    );
  }
}
