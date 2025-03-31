import 'package:seren_ai_flutter/services/ai/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/ai_tool_methods/models/task_request_models.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';

class CreateTaskResultModel extends AiRequestResultModel {
  final TaskModel task;
  final List<SearchUserResult>? userAssignmentResults;
  final Map<String, dynamic> createdFields;

  CreateTaskResultModel(
      {required this.task,
      required super.resultForAi,
      this.userAssignmentResults,
      this.createdFields = const {}})
      : super(resultType: AiRequestResultType.createTask);

  /// Factory constructor that processes the fields from the request
  factory CreateTaskResultModel.fromTaskAndRequest({
    required TaskModel task,
    required CreateTaskRequestModel request,
    required String resultForAi,
    List<SearchUserResult>? userAssignmentResults,
  }) {
    final createdFields = _processCreatedFields(request);

    return CreateTaskResultModel(
      task: task,
      resultForAi: resultForAi,
      userAssignmentResults: userAssignmentResults,
      createdFields: createdFields,
    );
  }

  /// Process fields that were set during creation
  static Map<String, dynamic> _processCreatedFields(
      CreateTaskRequestModel request) {
    final Map<String, dynamic> createdFields = {
      'name': request.taskName,
    };

    if (request.taskDescription != null) {
      createdFields['description'] = request.taskDescription;
    }
    if (request.taskStartDate != null) {
      createdFields['startDate'] = request.taskStartDate;
    }
    if (request.taskDueDate != null) {
      createdFields['dueDate'] = request.taskDueDate;
    }
    if (request.taskStatus != null) {
      createdFields['status'] = request.taskStatus;
    }
    if (request.taskPriority != null) {
      createdFields['priority'] = request.taskPriority;
    }
    if (request.estimateDurationMinutes != null) {
      createdFields['estimatedDuration'] = request.estimateDurationMinutes;
    }
    if (request.parentProjectName != null) {
      createdFields['project'] = request.parentProjectName;
    }
    if (request.assignedUserNames != null &&
        request.assignedUserNames!.isNotEmpty) {
      createdFields['assignees'] = request.assignedUserNames;
    }

    return createdFields;
  }

  factory CreateTaskResultModel.fromJson(Map<String, dynamic> json) {
    return CreateTaskResultModel(
      // Adjustment to fit old and new data structures
      task: TaskModel.fromJson(json['task'] ?? json['joined_task']['task']),
      resultForAi: json['result_for_ai'],
      createdFields: json['created_fields'] ?? {},
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toJson()
      ..addAll({
        'task': task.toJson(),
        'created_fields': createdFields,
      });
  }
}
