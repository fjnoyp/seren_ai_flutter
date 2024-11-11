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

abstract class AiInfoRequestModel implements AiRequestModel {
  final AiInfoRequestType infoRequestType;
  final Map<String, String>? args;
  final bool showOnly;

  AiInfoRequestModel({
    required this.infoRequestType,
    this.args,
    this.showOnly = true,
  });

  @override
  AiRequestType get requestType => AiRequestType.infoRequest;

  factory AiInfoRequestModel.fromJson(Map<String, dynamic> json) {
    try {
      final infoRequestType =
          AiInfoRequestType.fromString(json['info_request_type']);

      return switch (infoRequestType) {
        AiInfoRequestType.shiftAssignments =>
          ShiftAssignmentsRequestModel.fromJson(json),
        AiInfoRequestType.shiftLogs => ShiftLogsRequestModel.fromJson(json),
      };
    } catch (e) {
      throw ArgumentError('Invalid AiInfoRequestModel: $e');
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
