import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_request_model.dart';

/// Subtypes of UI Action Type
enum AiUIActionRequestType {
  shiftsPage('shifts_page');

  final String value;
  const AiUIActionRequestType(this.value);

  factory AiUIActionRequestType.fromString(String value) {
    return AiUIActionRequestType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Invalid AiUIActionType: $value'),
    );
  }
}

class AiUiActionRequestModel extends AiRequestModel {
  final AiUIActionRequestType uiActionType;

  AiUiActionRequestModel({
    required this.uiActionType,
    super.args,
  }) : super(AiRequestType.uiAction);

  factory AiUiActionRequestModel.fromJson(Map<String, dynamic> json) {
    return AiUiActionRequestModel(
      args: json['args'],
      uiActionType:
          AiUIActionRequestType.fromString(json['ui_action_request_type']),
    );
  }

  @override
  String toString() {
    return 'AiUiActionRequestModel(uiActionType: $uiActionType, args: $args)';
  }
}
