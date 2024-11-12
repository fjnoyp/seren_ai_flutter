import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_request_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/task_request_models.dart';

/// Subtypes of Action Request Type
enum AiActionRequestType {
  toggleClockInOrOut('toggle_clock_in_or_out'),
  createTask('create_task'),
  updateTaskFields('update_task_fields'),
  deleteTask('delete_task'),
  assignUserToTask('assign_user_to_task');

  final String value;
  const AiActionRequestType(this.value);

  factory AiActionRequestType.fromString(String value) {
    return AiActionRequestType.values.firstWhere(
      (type) => value == value,
      orElse: () => throw ArgumentError('Invalid AiActionRequestType: $value'),
    );
  }
}

/// Represent Action Request
class AiActionRequestModel extends AiRequestModel {
  final AiActionRequestType actionRequestType;

  AiActionRequestModel({
    required this.actionRequestType,
    super.args,
  }) : super(AiRequestType.actionRequest);

  factory AiActionRequestModel.fromJson(Map<String, dynamic> json) {
    final actionRequestType =
        AiActionRequestType.fromString(json['action_request_type']);

    switch (actionRequestType) {
      case AiActionRequestType.createTask:
        return CreateTaskRequestModel.fromJson(json);
      case AiActionRequestType.updateTaskFields:
        return UpdateTaskFieldsRequestModel.fromJson(json);
      case AiActionRequestType.deleteTask:
        return DeleteTaskRequestModel.fromJson(json);
      case AiActionRequestType.assignUserToTask:
        return AssignUserToTaskRequestModel.fromJson(json);
      case AiActionRequestType.toggleClockInOrOut:
        return AiActionRequestModel(
          args: json['args'],
          actionRequestType: actionRequestType,
        );
    }
  }

  @override
  String toString() {
    return 'AiActionRequestModel(actionRequestType: $actionRequestType, args: $args)';
  }
}
