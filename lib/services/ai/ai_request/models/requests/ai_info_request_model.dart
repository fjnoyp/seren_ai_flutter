import 'package:seren_ai_flutter/services/ai/ai_request/models/requests/ai_request_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/ai_tool_methods/models/shift_request_models.dart';
import 'package:seren_ai_flutter/services/data/tasks/ai_tool_methods/models/task_request_models.dart';
import 'package:seren_ai_flutter/services/data/notes/tool_methods/models/note_request_models.dart';

/// Subtypes of Info Request Type
enum AiInfoRequestType {
  shiftAssignments('shift_assignments'),
  shiftLogs('shift_logs'),
  currentShiftInfo('current_shift_info'),
  findTasks('find_tasks'),
  findNotes('find_notes');

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

  // TODO p3: defaults to true, in future get ai readable from the ai request

  AiInfoRequestModel({
    required this.infoRequestType,
    super.args,
  }) : super(AiRequestType.infoRequest);

  factory AiInfoRequestModel.fromJson(Map<String, dynamic> json) {
    final infoRequestType =
        AiInfoRequestType.fromString(json['info_request_type']);

    switch (infoRequestType) {
      case AiInfoRequestType.shiftAssignments:
        return ShiftAssignmentsRequestModel.fromJson(json);
      case AiInfoRequestType.shiftLogs:
        return ShiftLogsRequestModel.fromJson(json);
      case AiInfoRequestType.currentShiftInfo:
        return CurrentShiftInfoRequestModel.fromJson(json);
      case AiInfoRequestType.findTasks:
        return FindTasksRequestModel.fromJson(json);
      case AiInfoRequestType.findNotes:
        return FindNotesRequestModel.fromJson(json);
    }
  }

  @override
  String toString() {
    return 'AiInfoRequestModel(infoRequestType: $infoRequestType, args: $args)';
  }
}
