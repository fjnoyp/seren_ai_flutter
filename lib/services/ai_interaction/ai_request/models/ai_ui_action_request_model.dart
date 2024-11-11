import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/ai_request_model.dart';

/// Subtypes of UI Action Type 
enum AiUIActionRequestType {
  shiftsPage('shifts_page');

  final String value;
  const AiUIActionRequestType(this.value);

  static AiUIActionRequestType fromString(String value) {
    return AiUIActionRequestType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Invalid AiUIActionType: $value'),
    );
  }
}


class AiUiActionRequestModel extends AiRequestModel {
  final AiUIActionRequestType uiActionType;
  final Map<String, String>? args;

  AiUiActionRequestModel({
    required this.uiActionType,
    this.args,
  }) : super(AiRequestType.uiAction);


  static AiUiActionRequestModel fromJson(Map<String, dynamic> json) {
    return AiUiActionRequestModel(
      uiActionType: AiUIActionRequestType.fromString(json['ui_action_request_type']),
      args: json['args']?.cast<String, String>(),
    );
  }
}

