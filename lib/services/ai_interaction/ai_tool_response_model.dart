import 'dart:convert';

/*
========================================================
==== ATTENTION ====
This must be manually updated with seren-ai-langgraph ai_tool_response_model.py
========================================================
*/

enum AiResponseType {
  uiAction('ui_action'),
  infoRequest('info_request'),
  actionRequest('action_request');

  final String value;
  const AiResponseType(this.value);

  static AiResponseType fromString(String value) {
    return AiResponseType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Invalid AiResponseType: $value'),
    );
  }
}

enum AiActionRequestType {
  clockIn('clock_in'),
  clockOut('clock_out');

  final String value;
  const AiActionRequestType(this.value);

  static AiActionRequestType fromString(String value) {
    return AiActionRequestType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Invalid AiActionRequestType: $value'),
    );
  }
}

enum AiUIActionType {
  shiftsPage('shifts_page');

  final String value;
  const AiUIActionType(this.value);

  static AiUIActionType fromString(String value) {
    return AiUIActionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Invalid AiUIActionType: $value'),
    );
  }
}

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

abstract class AiToolResponseModel {
  final AiResponseType responseType;

  AiToolResponseModel(this.responseType);

  Map<String, dynamic> toJson() {
    return {'response_type': responseType.value};
  }

  static AiToolResponseModel fromJson(Map<String, dynamic> json) {
    final responseType = AiResponseType.fromString(json['response_type']);

    switch (responseType) {
      case AiResponseType.uiAction:
        return AiUiActionModel.fromJson(json);
      case AiResponseType.infoRequest:
        return AiInfoRequestModel.fromJson(json);
      case AiResponseType.actionRequest:
        return AiActionRequestModel.fromJson(json);
    }
  }

  static List<AiToolResponseModel> fromJsonList(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => AiToolResponseModel.fromJson(json)).toList();
  }
}

class AiActionRequestModel extends AiToolResponseModel {
  final AiActionRequestType actionRequestType;
  final Map<String, String>? args;

  AiActionRequestModel({
    required this.actionRequestType,
    this.args,
  }) : super(AiResponseType.actionRequest);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'action_request_type': actionRequestType.value,
      'args': args,
    };
  }

  static AiActionRequestModel fromJson(Map<String, dynamic> json) {
    return AiActionRequestModel(
      actionRequestType: AiActionRequestType.fromString(json['action_request_type']),
      args: json['args']?.cast<String, String>(),
    );
  }
}

class AiUiActionModel extends AiToolResponseModel {
  final AiUIActionType uiActionType;
  final Map<String, String>? args;

  AiUiActionModel({
    required this.uiActionType,
    this.args,
  }) : super(AiResponseType.uiAction);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'ui_action_type': uiActionType.value,
      'args': args,
    };
  }

  static AiUiActionModel fromJson(Map<String, dynamic> json) {
    return AiUiActionModel(
      uiActionType: AiUIActionType.fromString(json['ui_action_type']),
      args: json['args']?.cast<String, String>(),
    );
  }
}

class AiInfoRequestModel extends AiToolResponseModel {
  final AiInfoRequestType infoRequestType;
  final Map<String, String>? args;
  final bool showOnly;

  AiInfoRequestModel({
    required this.infoRequestType,
    this.args,
    this.showOnly = true,
  }) : super(AiResponseType.infoRequest);

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
