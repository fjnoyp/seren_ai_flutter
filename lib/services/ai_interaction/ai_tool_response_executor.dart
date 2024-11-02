import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_chat_service_provider.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_tool_response_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/last_ai_message_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/shift_tool_methods.dart';


/// Encapsulate information to return to ai
/// And possibly show to the user
class ToolResponseResult extends AiResult {
  final String message;
  final bool showOnly;

  ToolResponseResult({required this.message, required this.showOnly});
}

final aiToolResponseExecutorProvider =
    Provider<AiToolResponseExecutor>(AiToolResponseExecutor.new);

class AiToolResponseExecutor {
  final Ref ref;
  final ShiftToolMethods shiftToolMethods = ShiftToolMethods();

  AiToolResponseExecutor(this.ref);

  void callbackAi(String message) {
    // TODO p0: send as tool message not as human message! 
    ref.read(aiChatServiceProvider).sendMessage(message);
  }

  void updateLastAiMessage(ToolResponseResult result) {
    ref.read(lastAiMessageListenerProvider.notifier).addLastToolResponseResult(result);
  }

  Future<List<ToolResponseResult>> executeToolResponses(
      List<AiToolResponseModel> toolResponses) async {
    final results = await getToolResponseResults(toolResponses);

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
  Future<List<ToolResponseResult>> getToolResponseResults(
      List<AiToolResponseModel> toolResponses) async {
    List<ToolResponseResult> results = [];

    // Iterate through identified tool responses
    for (var response in toolResponses) {
      switch (response.responseType) {
        case AiResponseType.uiAction:
          results.addAll(await _handleUiAction(response as AiUiActionModel));
          break;

        case AiResponseType.infoRequest:
          results.addAll(await _handleInfoRequest(response as AiInfoRequestModel));
          break;
          
        case AiResponseType.actionRequest:
          results.addAll(await _handleActionRequest(response as AiActionRequestModel));
          break;
      }
    }

    return results;
  }

  Future<List<ToolResponseResult>> _handleUiAction(AiUiActionModel uiAction) async {
    switch (uiAction.uiActionType) {
      case AiUIActionType.shiftsPage:
        // TODO p1: open shifts page
        return [];
      default:
        throw Exception('Unknown UI action type: ${uiAction.uiActionType}');
    }
  }

  Future<List<ToolResponseResult>> _handleInfoRequest(AiInfoRequestModel infoRequest) async {
    switch (infoRequest.infoRequestType) {
      case AiInfoRequestType.shiftHistory:
        // TODO p1: determine how this will be used first 
        return [];
      case AiInfoRequestType.currentShift:
        final shiftInfoResult = await shiftToolMethods
            .getCurrentShiftInfo(ref: ref, infoRequest: infoRequest);
        return [shiftInfoResult];
      default:
        throw Exception('Unknown info request type: ${infoRequest.infoRequestType}');
    }
  }

  Future<List<ToolResponseResult>> _handleActionRequest(AiActionRequestModel actionRequest) async {
    switch (actionRequest.actionRequestType) {
      case AiActionRequestType.clockIn:
        return [await shiftToolMethods.clockIn(ref: ref)];
      case AiActionRequestType.clockOut:
        return [await shiftToolMethods.clockOut(ref: ref)];
      default:
        throw Exception('Unknown action request type: ${actionRequest.actionRequestType}');
    }
  }
}
