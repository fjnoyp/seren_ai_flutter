import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_request_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_request_models.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/task_request_models.dart';

/// Subtypes of Info Request Type
enum AiInfoRequestType {
  shiftAssignments('shift_assignments'),
  shiftLogs('shift_logs'),
  findTasks('find_tasks');

  final String value;
  const AiInfoRequestType(this.value);

  factory AiInfoRequestType.fromString(String value) {
    return AiInfoRequestType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Invalid AiInfoRequestType: $value'),
    );
  }
}

class AiInfoRequestModel extends AiRequestModel {
  final AiInfoRequestType infoRequestType;
  final bool showOnly;

  AiInfoRequestModel({
    required this.infoRequestType,
    super.args,
    this.showOnly = true,
  }) : super(AiRequestType.infoRequest);

  factory AiInfoRequestModel.fromJson(Map<String, dynamic> json) {
    final infoRequestType =
        AiInfoRequestType.fromString(json['info_request_type']);

    switch (infoRequestType) {
      case AiInfoRequestType.shiftAssignments:
        return ShiftAssignmentsRequestModel.fromJson(json);
      case AiInfoRequestType.shiftLogs:
        return ShiftLogsRequestModel.fromJson(json);
      case AiInfoRequestType.findTasks:
        return FindTasksRequestModel.fromJson(json);
    }
  }

  @override
  String toString() {
    return 'AiInfoRequestModel(infoRequestType: $infoRequestType, showOnly: $showOnly, args: $args)';
  }
}
