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
}

final aiRequestExecutorProvider =
    Provider<AiRequestExecutor>(AiRequestExecutor.new);

class AiRequestExecutor {
  final Ref ref;
  final ShiftToolMethods shiftToolMethods = ShiftToolMethods();

  AiRequestExecutor(this.ref);

  void callbackAi(String message) {
    // TODO p0: send as tool message not as human message!
    //ref.read(aiChatServiceProvider).sendMessage(message);
  }

  void updateLastAiMessage(AiRequestResult result) {
    ref
        .read(lastAiMessageListenerProvider.notifier)
        .addLastToolResponseResult(result);
  }

  Future<List<AiRequestResult>> executeAiRequests(
      List<AiRequestModel> aiRequests) async {
    final results = await getToolResponseResults(aiRequests);

    for (var result in results) {
      if (result.showOnly) {
        updateLastAiMessage(result);
      } else {
        callbackAi(result.message);
      }
    }

    return results;
  }

  // Route ToolResponse to the correct method
  Future<List<AiRequestResult>> getToolResponseResults(
      List<AiRequestModel> toolResponses) async {
    List<AiRequestResult> results = [];

    // Iterate through identified tool responses
    for (var response in toolResponses) {
      switch (response.requestType) {
        case AiRequestType.uiAction:
          results.addAll(
              await _handleUiActionRequest(response as AiUiActionRequestModel));
          break;

        case AiRequestType.infoRequest:
          results
              .addAll(await _handleInfoRequest(response as AiInfoRequestModel));
          break;

        case AiRequestType.actionRequest:
          results.addAll(
              await _handleActionRequest(response as AiActionRequestModel));
          break;
      }
    }

    return results;
  }

  Future<List<AiRequestResult>> _handleUiActionRequest(
      AiUiActionRequestModel uiAction) async {
    switch (uiAction.uiActionType) {
      case AiUIActionRequestType.shiftsPage:
        // TODO p1: open shifts page
        return [];
      default:
        throw Exception('Unknown UI action type: ${uiAction.uiActionType}');
    }
  }

  Future<List<AiRequestResult>> _handleInfoRequest(
      AiInfoRequestModel infoRequest) async {
    switch (infoRequest.infoRequestType) {
      case AiInfoRequestType.shiftHistory:
        // TODO p1: determine how this will be used first
        return [];
      case AiInfoRequestType.currentShift:
        final shiftInfoResult = await shiftToolMethods.getCurrentShiftInfo(
            ref: ref, infoRequest: infoRequest);
        return [shiftInfoResult];
      default:
        throw Exception(
            'Unknown info request type: ${infoRequest.infoRequestType}');
    }
  }

  Future<List<AiRequestResult>> _handleActionRequest(
      AiActionRequestModel actionRequest) async {
    switch (actionRequest.actionRequestType) {
      case AiActionRequestType.clockIn:
        return [await shiftToolMethods.clockIn(ref: ref)];
      case AiActionRequestType.clockOut:
        return [await shiftToolMethods.clockOut(ref: ref)];
      default:
        throw Exception(
            'Unknown action request type: ${actionRequest.actionRequestType}');
    }
  }
}
