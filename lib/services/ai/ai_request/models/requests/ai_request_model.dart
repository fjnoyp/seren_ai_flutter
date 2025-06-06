import 'dart:convert';

import 'package:seren_ai_flutter/services/ai/ai_request/models/requests/ai_action_request_model.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/models/requests/ai_info_request_model.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/models/requests/ai_ui_action_request_model.dart';

/// Type of Request from AI
enum AiRequestType {
  uiAction('ui_action_request'),
  infoRequest('info_request'),
  actionRequest('action_request');

  final String value;
  const AiRequestType(this.value);

  static AiRequestType fromString(String value) {
    return AiRequestType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Invalid AiResponseType: $value'),
    );
  }
}

/// Represent an Ai Request for an action, info, or ui action
abstract class AiRequestModel {
  final AiRequestType requestType;
  final Map<String, dynamic>? args;

  AiRequestModel(this.requestType, {this.args});

  factory AiRequestModel.fromJson(Map<String, dynamic> json) {
    final requestType = AiRequestType.fromString(json['request_type']);

    switch (requestType) {
      case AiRequestType.uiAction:
        return AiUiActionRequestModel.fromJson(json);
      case AiRequestType.infoRequest:
        return AiInfoRequestModel.fromJson(json);
      case AiRequestType.actionRequest:
        return AiActionRequestModel.fromJson(json);
    }
  }

  static List<AiRequestModel> fromJsonList(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => AiRequestModel.fromJson(json)).toList();
  }
}
