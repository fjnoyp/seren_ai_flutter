import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_chat_service_provider.dart';
import 'package:seren_ai_flutter/services/ai_interaction/last_ai_message_listener_provider.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/ai_action_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/ai_info_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/ai_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/ai_ui_action_request_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/shift_tool_methods.dart';

/// Result of an AI Request execution
class AiRequestResult extends AiResult {
  final String message;
  final bool showOnly;

  AiRequestResult({required this.message, required this.showOnly});

  copyWith({required String message, required bool showOnly}) {
    return AiRequestResult(message: message, showOnly: showOnly);
  }
}

final aiRequestExecutorProvider =
    Provider<AiRequestExecutor>(AiRequestExecutor.new);

class AiRequestExecutor {
  final Ref ref;
  final ShiftToolMethods shiftToolMethods = ShiftToolMethods();

  AiRequestExecutor(this.ref);

  Future<AiRequestResult> executeAiRequest(
      AiRequestModel aiRequest) async {
    final result = await getToolResponseResult(aiRequest);
    return result;
  }

  // Route ToolResponse to the correct method
  Future<AiRequestResult> getToolResponseResult(
      AiRequestModel toolResponse) async {

    AiRequestResult result; 

    // Iterate through identified tool responses
    switch (toolResponse.requestType) {
      case AiRequestType.uiAction:
        result = await _handleUiActionRequest(toolResponse as AiUiActionRequestModel);
        break;

        case AiRequestType.infoRequest:
        result = await _handleInfoRequest(toolResponse as AiInfoRequestModel);
        break;

      case AiRequestType.actionRequest:
        result = await _handleActionRequest(toolResponse as AiActionRequestModel);
        break;

      default:
        throw Exception('Unknown tool response type: ${toolResponse.requestType}');
    }

    return result;
  }

  Future<AiRequestResult> _handleUiActionRequest(
      AiUiActionRequestModel uiAction) async {
    switch (uiAction.uiActionType) {
      case AiUIActionRequestType.shiftsPage:
        // TODO p1: open shifts page
        throw Exception('Not implemented');
      default:
        throw Exception('Unknown UI action type: ${uiAction.uiActionType}');
    }
  }

  Future<AiRequestResult> _handleInfoRequest(
      AiInfoRequestModel infoRequest) async {
    switch (infoRequest.infoRequestType) {
      case AiInfoRequestType.shiftHistory:
        // TODO p1: determine how this will be used first
        throw Exception('Not implemented');
      case AiInfoRequestType.currentShift:
        final shiftInfoResult = await shiftToolMethods.getCurrentShiftInfo(
            ref: ref, infoRequest: infoRequest);
        return shiftInfoResult;
      default:
        throw Exception(
            'Unknown info request type: ${infoRequest.infoRequestType}');
    }
  }

  Future<AiRequestResult> _handleActionRequest(
      AiActionRequestModel actionRequest) async {
    switch (actionRequest.actionRequestType) {
      case AiActionRequestType.clockIn:
        return await shiftToolMethods.clockIn(ref: ref);
      case AiActionRequestType.clockOut:
        return await shiftToolMethods.clockOut(ref: ref);
      default:
        throw Exception(
            'Unknown action request type: ${actionRequest.actionRequestType}');
    }
  }
}
