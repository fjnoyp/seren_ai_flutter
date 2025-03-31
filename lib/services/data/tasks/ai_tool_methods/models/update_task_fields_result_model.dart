import 'package:seren_ai_flutter/services/ai/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/ai_tool_methods/models/task_request_models.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/ai_tool_methods/ai_date_parser.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';

class UpdateTaskFieldsResultModel extends AiRequestResultModel {
  final TaskModel task;
  final Map<String, Map<String, dynamic>> changedFields;

  UpdateTaskFieldsResultModel(
      {required this.task,
      required super.resultForAi,
      this.changedFields = const {}})
      : super(resultType: AiRequestResultType.updateTaskFields);

  /// Factory constructor that processes the changes between original task and request
  factory UpdateTaskFieldsResultModel.fromTaskAndRequest({
    required TaskModel originalTask,
    required TaskModel updatedTask,
    required UpdateTaskFieldsRequestModel request,
    required String resultForAi,
    Map<String, Map<String, dynamic>>? additionalChanges,
  }) {
    final changedFields = _processChanges(
      originalTask: originalTask,
      updatedTask: updatedTask,
      request: request,
      additionalChanges: additionalChanges,
    );

    return UpdateTaskFieldsResultModel(
      task: updatedTask,
      resultForAi: resultForAi,
      changedFields: changedFields,
    );
  }

  /// Process changes between original and updated task
  static Map<String, Map<String, dynamic>> _processChanges({
    required TaskModel originalTask,
    required TaskModel updatedTask,
    required UpdateTaskFieldsRequestModel request,
    Map<String, Map<String, dynamic>>? additionalChanges,
  }) {
    final Map<String, Map<String, dynamic>> changedFields = {};

    // Compare and track changes for name
    if (request.taskName != originalTask.name) {
      changedFields['name'] = {
        'old': originalTask.name,
        'new': request.taskName,
      };
    }

    // Description
    if (request.taskDescription != null &&
        request.taskDescription != originalTask.description) {
      changedFields['description'] = {
        'old': originalTask.description,
        'new': request.taskDescription,
      };
    }

    // Start date
    if (request.taskStartDate != null) {
      final newStartDate =
          AiDateParser.parseIsoIntoLocalThenUTC(request.taskStartDate);
      if (newStartDate != originalTask.startDateTime) {
        changedFields['startDate'] = {
          'old': originalTask.startDateTime,
          'new': newStartDate,
        };
      }
    }

    // Due date
    if (request.taskDueDate != null) {
      final newDueDate =
          AiDateParser.parseIsoIntoLocalThenUTC(request.taskDueDate);
      if (newDueDate != originalTask.dueDate) {
        changedFields['dueDate'] = {
          'old': originalTask.dueDate,
          'new': newDueDate,
        };
      }
    }

    // Status
    if (request.taskStatus != null) {
      final newStatus = StatusEnum.tryParse(request.taskStatus);
      if (newStatus != originalTask.status) {
        changedFields['status'] = {
          'old': originalTask.status?.name,
          'new': newStatus?.name,
        };
      }
    }

    // Priority
    if (request.taskPriority != null) {
      final newPriority = PriorityEnum.tryParse(request.taskPriority);
      if (newPriority != originalTask.priority) {
        changedFields['priority'] = {
          'old': originalTask.priority?.name,
          'new': newPriority?.name,
        };
      }
    }

    // Estimated duration
    if (request.estimateDurationMinutes != null &&
        request.estimateDurationMinutes !=
            originalTask.estimatedDurationMinutes) {
      changedFields['estimatedDuration'] = {
        'old': originalTask.estimatedDurationMinutes,
        'new': request.estimateDurationMinutes,
      };
    }

    // Add any additional changes (like project or assignees that require repository access)
    if (additionalChanges != null) {
      changedFields.addAll(additionalChanges);
    }

    return changedFields;
  }

  factory UpdateTaskFieldsResultModel.fromJson(Map<String, dynamic> json) {
    return UpdateTaskFieldsResultModel(
      // Adjustment to fit old and new data structures
      task: TaskModel.fromJson(json['task'] ?? json['joined_task']['task']),
      resultForAi: json['result_for_ai'],
      changedFields: json['changed_fields'] != null
          ? Map<String, Map<String, dynamic>>.from(json['changed_fields'])
          : {},
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toJson()
      ..addAll({
        'task': task.toJson(),
        'changed_fields': changedFields,
      });
  }
}
