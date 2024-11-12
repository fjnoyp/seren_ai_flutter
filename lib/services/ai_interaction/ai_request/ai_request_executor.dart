import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_action_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_info_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_ui_action_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/error_request_result_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_request_models.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/shift_tool_methods.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/task_request_models.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/task_tool_methods.dart';

final aiRequestExecutorProvider =
    Provider<AiRequestExecutor>(AiRequestExecutor.new);

class AiRequestExecutor {
  final Ref ref;
  final ShiftToolMethods shiftToolMethods = ShiftToolMethods();
  final TaskToolMethods taskToolMethods = TaskToolMethods();
  AiRequestExecutor(this.ref);

  Future<AiRequestResultModel> executeAiRequest(
    AiRequestModel aiRequest, {
    required bool navigate,
  }) async {
    final result = await getToolResponseResult(aiRequest, navigate: navigate);
    return result;
  }

  // Route ToolResponse to the correct method
  Future<AiRequestResultModel> getToolResponseResult(
    AiRequestModel aiRequest, {
    required bool navigate,
  }) async {
    AiRequestResultModel result;

    // Iterate through identified tool responses
    switch (aiRequest.requestType) {
      case AiRequestType.uiAction:
        result =
            await _handleUiActionRequest(aiRequest as AiUiActionRequestModel);
        break;

      case AiRequestType.infoRequest:
        result = await _handleInfoRequest(aiRequest as AiInfoRequestModel);
        break;

      case AiRequestType.actionRequest:
        result = await _handleActionRequest(
          aiRequest as AiActionRequestModel,
          navigate: navigate,
        );
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
        return ErrorRequestResultModel(
            resultForAi: 'Not implemented', showOnly: true);
      default:
        return ErrorRequestResultModel(
            resultForAi: 'Unknown UI action: ${uiAction.toString()}',
            showOnly: true);
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

      case AiInfoRequestType.findTasks:
        return await taskToolMethods.findTasks(
            ref: ref, infoRequest: infoRequest as FindTasksRequestModel);

      default:
        return ErrorRequestResultModel(
            resultForAi: 'Unknown info request: ${infoRequest.toString()}',
            showOnly: true);
    }
  }

  Future<AiRequestResultModel> _handleActionRequest(
    AiActionRequestModel actionRequest, {
    required bool navigate,
  }) async {
    switch (actionRequest.actionRequestType) {
      case AiActionRequestType.toggleClockInOrOut:
        return await shiftToolMethods.toggleClockInOut(ref: ref);

      case AiActionRequestType.createTask:
        return await taskToolMethods.createTask(
            ref: ref,
            actionRequest: actionRequest as CreateTaskRequestModel,
            autoNavigate: navigate);

      case AiActionRequestType.updateTaskFields:
        return await taskToolMethods.updateTaskFields(
            ref: ref,
            actionRequest: actionRequest as UpdateTaskFieldsRequestModel);

      case AiActionRequestType.deleteTask:
        return await taskToolMethods.deleteTask(
            ref: ref, actionRequest: actionRequest as DeleteTaskRequestModel);

      case AiActionRequestType.assignUserToTask:
        return await taskToolMethods.assignUserToTask(
            ref: ref,
            actionRequest: actionRequest as AssignUserToTaskRequestModel);
    }
  }
}
