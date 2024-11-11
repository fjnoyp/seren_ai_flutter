import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_action_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_info_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_ui_action_request_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/shift_tool_methods.dart';




final aiRequestExecutorProvider =
    Provider<AiRequestExecutor>(AiRequestExecutor.new);

class AiRequestExecutor {
  final Ref ref;
  final ShiftToolMethods shiftToolMethods = ShiftToolMethods();

  AiRequestExecutor(this.ref);

  Future<AiRequestResultModel> executeAiRequest(
      AiRequestModel aiRequest) async {
    final result = await getToolResponseResult(aiRequest);
    return result;
  }

  // Route ToolResponse to the correct method
  Future<AiRequestResultModel> getToolResponseResult(
      AiRequestModel aiRequest) async {

    AiRequestResultModel result; 

    // Iterate through identified tool responses
    switch (aiRequest.requestType) {
      case AiRequestType.uiAction:
        result = await _handleUiActionRequest(aiRequest as AiUiActionRequestModel);
        break;

        case AiRequestType.infoRequest:
        result = await _handleInfoRequest(aiRequest as AiInfoRequestModel);
        break;

      case AiRequestType.actionRequest:
        result = await _handleActionRequest(aiRequest as AiActionRequestModel);
        break;

      default:
        throw Exception('Unknown tool response type: ${aiRequest.requestType}');
    }

    return result;
  }

  Future<AiRequestResultModel> _handleUiActionRequest(
      AiUiActionRequestModel uiAction) async {
    switch (uiAction.uiActionType) {
      case AiUIActionRequestType.shiftsPage:
        // TODO p1: open shifts page
        throw Exception('Not implemented');
      default:
        throw Exception('Unknown UI action type: ${uiAction.uiActionType}');
    }
  }

  Future<AiRequestResultModel> _handleInfoRequest(
      AiInfoRequestModel infoRequest) async {
    switch (infoRequest.infoRequestType) {
      case AiInfoRequestType.shiftAssignments:
        return await shiftToolMethods.getShiftAssignments(
            ref: ref, infoRequest: infoRequest as ShiftAssignmentsRequestModel);

      case AiInfoRequestType.shiftLogs:
        return await shiftToolMethods.getShiftLogs(
            ref: ref, infoRequest: infoRequest as ShiftLogsRequestModel);

      // case AiInfoRequestType.currentShift:
      //   final shiftInfoResult = await shiftToolMethods.getCurrentShiftInfo(
      //       ref: ref, infoRequest: infoRequest);
      //   return shiftInfoResult;
      default:
        throw Exception(
            'Unknown info request type: ${infoRequest.infoRequestType}');
    }
  }

  Future<AiRequestResultModel> _handleActionRequest(
      AiActionRequestModel actionRequest) async {
    switch (actionRequest.actionRequestType) {
      case AiActionRequestType.toggleClockInOrOut:
        return await shiftToolMethods.toggleClockInOut(ref: ref);
      default:
        throw Exception(
            'Unknown action request type: ${actionRequest.actionRequestType}');
    }
  }
}
