import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/ai_request_model.dart';

/// Subtypes of Info Request Type 
enum AiInfoRequestType {
  shiftHistory('shift_history'),
  currentShift('current_shift');

  final String value;
  const AiInfoRequestType(this.value);

  static AiInfoRequestType fromString(String value) {
    return AiInfoRequestType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Invalid AiInfoRequestType: $value'),
    );
  }
}
class AiInfoRequestModel extends AiRequestModel {
  final AiInfoRequestType infoRequestType;
  final Map<String, String>? args;
  final bool showOnly;

  AiInfoRequestModel({
    required this.infoRequestType,
    this.args,
    this.showOnly = true,
  }) : super(AiRequestType.infoRequest);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'info_request_type': infoRequestType.value,
      'args': args,
      'show_only': showOnly,
    };
  }

  static AiInfoRequestModel fromJson(Map<String, dynamic> json) {
    return AiInfoRequestModel(
      infoRequestType: AiInfoRequestType.fromString(json['info_request_type']),
      args: json['args']?.cast<String, String>(),
      showOnly: json['show_only'] ?? true,
    );
  }
}