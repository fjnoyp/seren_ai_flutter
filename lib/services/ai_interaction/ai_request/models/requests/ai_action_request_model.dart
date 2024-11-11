import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_request_model.dart';

/// Subtypes of Action Request Type 
enum AiActionRequestType {
  toggleClockInOrOut('toggle_clock_in_or_out');
  
  final String value;
  const AiActionRequestType(this.value);

  static AiActionRequestType fromString(String value) {
    return AiActionRequestType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Invalid AiActionRequestType: $value'),
    );
  }
}

/// Represent Action Request 
class AiActionRequestModel extends AiRequestModel {
  final AiActionRequestType actionRequestType;
  final Map<String, String>? args;

  AiActionRequestModel({
    required this.actionRequestType,
    this.args,
  }) : super(AiRequestType.actionRequest);

  static AiActionRequestModel fromJson(Map<String, dynamic> json) {
    return AiActionRequestModel(
      actionRequestType: AiActionRequestType.fromString(json['action_request_type']),
      args: json['args']?.cast<String, String>(),
    );
  }
}


