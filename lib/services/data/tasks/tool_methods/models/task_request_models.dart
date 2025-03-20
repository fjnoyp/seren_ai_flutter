import 'package:seren_ai_flutter/services/ai/ai_request/models/requests/ai_action_request_model.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/models/requests/ai_info_request_model.dart';

// Dart class representation of python task_tool.py generated requests

class FindTasksRequestModel extends AiInfoRequestModel {
  final String? taskName;
  final String? taskDescription;
  final String? taskStatus;
  final String? taskPriority;
  final int? estimateDurationMinutes;
  final String? parentProjectName;
  final String? authorUserName;
  final List<String>? assignedUserNames;
  final String? taskDueDateStart;
  final String? taskDueDateEnd;
  final String? taskCreatedDateStart;
  final String? taskCreatedDateEnd;

  FindTasksRequestModel({
    this.taskName,
    this.taskDescription,
    this.taskStatus,
    this.taskPriority,
    this.estimateDurationMinutes,
    this.parentProjectName,
    this.authorUserName,
    this.assignedUserNames,
    this.taskDueDateStart,
    this.taskDueDateEnd,
    this.taskCreatedDateStart,
    this.taskCreatedDateEnd,
    super.showOnly = true,
    super.args,
  }) : super(infoRequestType: AiInfoRequestType.findTasks);

  static FindTasksRequestModel fromJson(Map<String, dynamic> json) {
    return FindTasksRequestModel(
      args: json['args'],
      taskName: json['args']['task_name'],
      taskDescription: json['args']['task_description'],
      taskStatus: json['args']['task_status'],
      taskPriority: json['args']['task_priority'],
      estimateDurationMinutes: json['args']['estimate_duration_minutes'],
      parentProjectName: json['args']['parent_project_name'],
      authorUserName: json['args']['author_user_name'],
      assignedUserNames: json['args']['assigned_user_names']?.cast<String>(),
      taskDueDateStart: json['args']['task_due_date_start'],
      taskDueDateEnd: json['args']['task_due_date_end'],
      taskCreatedDateStart: json['args']['task_created_date_start'],
      taskCreatedDateEnd: json['args']['task_created_date_end'],
      showOnly: json['show_only'] ?? true,
    );
  }
}

class AddCommentToTaskRequestModel extends AiActionRequestModel {
  final String taskName;
  final String comment;

  AddCommentToTaskRequestModel({
    required this.taskName,
    required this.comment,
    super.args,
  }) : super(actionRequestType: AiActionRequestType.addCommentToTask);

  static AddCommentToTaskRequestModel fromJson(Map<String, dynamic> json) {
    return AddCommentToTaskRequestModel(
      args: json['args'],
      taskName: json['args']['task_name'],
      comment: json['args']['comment'],
    );
  }
}

class CreateTaskRequestModel extends AiActionRequestModel {
  final String taskName;
  final String? taskDescription;
  final String? taskStartDate; // Must be in ISO 8601 format
  final String? taskDueDate; // Must be in ISO 8601 format
  final String? taskPriority; // Must be: veryLow, low, normal, high, veryHigh
  final String? taskStatus; // Must be: todo, inProgress, done
  final int? estimateDurationMinutes;
  final List<String>? assignedUserNames;
  final String? parentProjectName;

  CreateTaskRequestModel({
    required this.taskName,
    this.taskDescription,
    this.taskStartDate,
    this.taskDueDate,
    this.taskPriority,
    this.taskStatus,
    this.estimateDurationMinutes,
    this.assignedUserNames,
    this.parentProjectName,
    super.args,
  }) : super(actionRequestType: AiActionRequestType.createTask);

  static CreateTaskRequestModel fromJson(Map<String, dynamic> json) {
    return CreateTaskRequestModel(
      args: json['args'],
      taskName: json['args']['task_name'],
      taskDescription: json['args']['task_description'],
      taskStartDate: json['args']['task_start_date'],
      taskDueDate: json['args']['task_due_date'],
      taskPriority: json['args']['task_priority'],
      taskStatus: json['args']['task_status'],
      estimateDurationMinutes: json['args']['estimate_duration_minutes'],
      assignedUserNames: json['args']['assigned_user_names']?.cast<String>(),
      parentProjectName: json['args']['parent_project_name'],
    );
  }
}

class UpdateTaskFieldsRequestModel extends AiActionRequestModel {
  final String taskName;
  final String? taskDescription;
  final String? taskStartDate;
  final String? taskDueDate;
  final String? taskStatus;
  final String? taskPriority;
  final int? estimateDurationMinutes;
  final List<String>? assignedUserNames;
  final String? parentProjectName;

  UpdateTaskFieldsRequestModel({
    required this.taskName,
    this.taskDescription,
    this.taskStartDate,
    this.taskDueDate,
    this.taskStatus,
    this.taskPriority,
    this.estimateDurationMinutes,
    this.assignedUserNames,
    this.parentProjectName,
    super.args,
  }) : super(actionRequestType: AiActionRequestType.updateTaskFields);

  static UpdateTaskFieldsRequestModel fromJson(Map<String, dynamic> json) {
    return UpdateTaskFieldsRequestModel(
      args: json['args'],
      taskName: json['args']['task_name'],
      taskDescription: json['args']['task_description'],
      taskStartDate: json['args']['task_start_date'],
      taskDueDate: json['args']['task_due_date'],
      taskStatus: json['args']['task_status'],
      taskPriority: json['args']['task_priority'],
      estimateDurationMinutes: json['args']['estimate_duration_minutes'],
      assignedUserNames: json['args']['assigned_user_names']?.cast<String>(),
      parentProjectName: json['args']['parent_project_name'],
    );
  }
}

class DeleteTaskRequestModel extends AiActionRequestModel {
  final String taskName;

  DeleteTaskRequestModel({
    required this.taskName,
    super.args,
  }) : super(actionRequestType: AiActionRequestType.deleteTask);

  static DeleteTaskRequestModel fromJson(Map<String, dynamic> json) {
    return DeleteTaskRequestModel(
      args: json['args'],
      taskName: json['args']['task_name'],
    );
  }
}

class AssignUserToTaskRequestModel extends AiActionRequestModel {
  final String taskName;
  final String userName;

  AssignUserToTaskRequestModel({
    required this.taskName,
    required this.userName,
    super.args,
  }) : super(actionRequestType: AiActionRequestType.assignUserToTask);

  static AssignUserToTaskRequestModel fromJson(Map<String, dynamic> json) {
    return AssignUserToTaskRequestModel(
      args: json['args'],
      taskName: json['args']['task_name'],
      userName: json['args']['user_name'],
    );
  }
}
