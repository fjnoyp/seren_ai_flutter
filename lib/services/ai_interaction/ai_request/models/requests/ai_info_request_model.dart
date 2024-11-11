import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_request_model.dart';

/// Subtypes of Info Request Type 
enum AiInfoRequestType {
  //shiftHistory('shift_history'),
  //currentShift('current_shift');
  shiftAssignments('shift_assignments'),
  shiftLogs('shift_logs');

  final String value;
  const AiInfoRequestType(this.value);

  static AiInfoRequestType fromString(String value) {
    return AiInfoRequestType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Invalid AiInfoRequestType: $value'),
    );
  }
}
abstract class AiInfoRequestModel extends AiRequestModel {
  final AiInfoRequestType infoRequestType;
  final Map<String, String>? args;
  final bool showOnly;

  AiInfoRequestModel({
    required this.infoRequestType,
    this.args,
    this.showOnly = true,
  }) : super(AiRequestType.infoRequest);

  static AiInfoRequestModel fromJson(Map<String, dynamic> json) {

    final infoRequestType = AiInfoRequestType.fromString(json['info_request_type']);

    switch(infoRequestType) {
      case AiInfoRequestType.shiftAssignments:
        return ShiftAssignmentsRequestModel.fromJson(json);
      case AiInfoRequestType.shiftLogs:
        return ShiftLogsRequestModel.fromJson(json);
      default:
        throw ArgumentError('Invalid AiInfoRequestType: ${json['info_request_type']}');
    }
  }
}


class ShiftAssignmentsRequestModel extends AiInfoRequestModel {

  final List<int> dayOffsetsToGet;

  ShiftAssignmentsRequestModel({
    required this.dayOffsetsToGet,
    super.showOnly = true,
  }) : super(infoRequestType: AiInfoRequestType.shiftAssignments);

  static ShiftAssignmentsRequestModel fromJson(Map<String, dynamic> json) {
    return ShiftAssignmentsRequestModel(
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
  }) : super(infoRequestType: AiInfoRequestType.shiftLogs);

  static ShiftLogsRequestModel fromJson(Map<String, dynamic> json) {
    return ShiftLogsRequestModel(
      dayOffsetsToGet: json['args']['day_offsets_to_get'].cast<int>(),
      showOnly: json['show_only'] ?? true,
    );
  }
}