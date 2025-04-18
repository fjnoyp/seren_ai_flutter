import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/current_route_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/models/requests/ai_action_request_model.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/models/requests/ai_info_request_model.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/models/requests/ai_request_model.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/models/requests/ai_ui_action_request_model.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/models/results/error_request_result_model.dart';
import 'package:seren_ai_flutter/services/data/notes/tool_methods/models/note_request_models.dart';
import 'package:seren_ai_flutter/services/data/notes/tool_methods/note_tool_methods.dart';
import 'package:seren_ai_flutter/services/data/shifts/ai_tool_methods/models/shift_request_models.dart';
import 'package:seren_ai_flutter/services/data/shifts/ai_tool_methods/shift_tool_methods.dart';
import 'package:seren_ai_flutter/services/data/tasks/ai_tool_methods/models/task_request_models.dart';
import 'package:seren_ai_flutter/services/data/tasks/ai_tool_methods/task_tool_methods.dart';

final aiRequestExecutorProvider =
    Provider<AiRequestExecutor>(AiRequestExecutor.new);

class AiRequestExecutor {
  final Ref ref;
  final ShiftToolMethods shiftToolMethods = ShiftToolMethods();
  final TaskToolMethods taskToolMethods = TaskToolMethods();
  final NoteToolMethods noteToolMethods = NoteToolMethods();

  AiRequestExecutor(this.ref);

  Future<AiRequestResultModel> executeAiRequest(
      AiRequestModel aiRequest) async {
    // Control whether data changes are shown via UI to the user
    final allowToolUiActions =
        !ref.read(currentRouteProvider).contains(AppRoutes.aiChats.name);

    final result = await _getToolResponseResult(allowToolUiActions, aiRequest);
    return result;
  }

  // Route ToolResponse to the correct method
  Future<AiRequestResultModel> _getToolResponseResult(
      bool allowToolUiActions, AiRequestModel aiRequest) async {
    AiRequestResultModel result;

    // Iterate through identified tool responses
    switch (aiRequest.requestType) {
      case AiRequestType.uiAction:
        result = await _handleUiActionRequest(
            allowToolUiActions, aiRequest as AiUiActionRequestModel);
        break;

      case AiRequestType.infoRequest:
        result = await _handleInfoRequest(
            allowToolUiActions, aiRequest as AiInfoRequestModel);
        break;

      case AiRequestType.actionRequest:
        result = await _handleActionRequest(
            allowToolUiActions, aiRequest as AiActionRequestModel);
        break;

      default:
        throw Exception('Unknown tool response type: ${aiRequest.requestType}');
    }

    return result;
  }

  Future<AiRequestResultModel> _handleUiActionRequest(
      bool allowToolUiActions, AiUiActionRequestModel uiAction) async {
    switch (uiAction.uiActionType) {
      case AiUIActionRequestType.shiftsPage:
        // TODO p1: open shifts page
        return ErrorRequestResultModel(resultForAi: 'Not implemented');
      default:
        return ErrorRequestResultModel(
            resultForAi: 'Unknown UI action: ${uiAction.toString()}');
    }
  }

  Future<AiRequestResultModel> _handleInfoRequest(
      bool allowToolUiActions, AiInfoRequestModel infoRequest) async {
    switch (infoRequest.infoRequestType) {
      case AiInfoRequestType.shiftAssignments:
        return await shiftToolMethods.getShiftAssignments(
            ref: ref,
            infoRequest: infoRequest as ShiftAssignmentsRequestModel,
            allowToolUiActions: allowToolUiActions);

      case AiInfoRequestType.shiftLogs:
        return await shiftToolMethods.getShiftLogs(
            ref: ref,
            infoRequest: infoRequest as ShiftLogsRequestModel,
            allowToolUiActions: allowToolUiActions);

      case AiInfoRequestType.findTasks:
        return await taskToolMethods.findTasks(
          ref: ref,
          infoRequest: infoRequest as FindTasksRequestModel,
          allowToolUiActions: allowToolUiActions,
        );

      default:
        return ErrorRequestResultModel(
            resultForAi: 'Unknown info request: ${infoRequest.toString()}');
    }
  }

  Future<AiRequestResultModel> _handleActionRequest(
      bool allowToolUiActions, AiActionRequestModel actionRequest) async {
    switch (actionRequest.actionRequestType) {
      case AiActionRequestType.toggleClockInOrOut:
        return await shiftToolMethods.toggleClockInOut(ref: ref);

      case AiActionRequestType.createTask:
        return await taskToolMethods.createTask(
            ref: ref,
            actionRequest: actionRequest as CreateTaskRequestModel,
            allowToolUiActions: allowToolUiActions);

      case AiActionRequestType.updateTaskFields:
        return await taskToolMethods.updateTaskFields(
            ref: ref,
            actionRequest: actionRequest as UpdateTaskFieldsRequestModel,
            allowToolUiActions: allowToolUiActions);

      case AiActionRequestType.deleteTask:
        return await taskToolMethods.deleteTask(
            ref: ref, actionRequest: actionRequest as DeleteTaskRequestModel);

      case AiActionRequestType.addCommentToTask:
        return await taskToolMethods.addCommentToTask(
            ref: ref,
            actionRequest: actionRequest as AddCommentToTaskRequestModel,
            allowToolUiActions: allowToolUiActions);

      case AiActionRequestType.showTasks:
        return await taskToolMethods.showTask(
            ref: ref, actionRequest: actionRequest as ShowTasksRequestModel);

      case AiActionRequestType.createNote:
        return await noteToolMethods.createNote(
            ref: ref,
            actionRequest: actionRequest as CreateNoteRequestModel,
            allowToolUiActions: allowToolUiActions);

      case AiActionRequestType.updateNote:
        return await noteToolMethods.updateNote(
            ref: ref,
            actionRequest: actionRequest as UpdateNoteRequestModel,
            allowToolUiActions: allowToolUiActions);

      case AiActionRequestType.shareNote:
      case AiActionRequestType.deleteNote:
      case AiActionRequestType.showNotes:
        return ErrorRequestResultModel(resultForAi: 'Not implemented');

      default:
        return ErrorRequestResultModel(
            resultForAi: 'Unknown action request: ${actionRequest.toString()}');
    }
  }
}
