import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_action_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_info_request_model.dart';

// Dart class representation of python task_tool.py generated requests 

class FindTasksRequestModel extends AiInfoRequestModel {
  final String? taskName;
  final String? taskDescription;
  final String? taskDueDate;
  final String? taskCreatedDate;
  final int? dateSearchRadiusDays;
  final String? taskStatus;
  final String? taskPriority;
  final int? estimateDurationMinutes;
  final String? parentProjectName;
  final String? authorUserName;
  final List<String>? assignedUserNames;  

  FindTasksRequestModel({
    this.taskName,
    this.taskDescription,
    this.taskDueDate,
    this.taskCreatedDate,
    this.dateSearchRadiusDays,
    this.taskStatus,
    this.taskPriority,
    this.estimateDurationMinutes,
    this.parentProjectName,
    this.authorUserName,
    this.assignedUserNames,
    super.showOnly = true,
    super.args,
  }) : super(infoRequestType: AiInfoRequestType.findTasks);

  static FindTasksRequestModel fromJson(Map<String, dynamic> json) {
    return FindTasksRequestModel(
      args: json['args'],
      taskName: json['args']['task_name'],
      taskDescription: json['args']['task_description'],
      taskDueDate: json['args']['task_due_date'],
      taskCreatedDate: json['args']['task_created_date'],
      dateSearchRadiusDays: json['args']['date_search_radius_days'],
      taskStatus: json['args']['task_status'],
      taskPriority: json['args']['task_priority'],
      estimateDurationMinutes: json['args']['estimate_duration_minutes'],
      parentProjectName: json['args']['parent_project_name'],
      authorUserName: json['args']['author_user_name'],
      assignedUserNames: json['args']['assigned_user_names']?.cast<String>(),
      showOnly: json['show_only'] ?? true,
    );
  }
}

class CreateTaskRequestModel extends AiActionRequestModel {
  final String taskName;
  final String? taskDescription;
  final String? taskDueDate;
  final String? taskPriority;
  final int? estimateDurationMinutes;

  CreateTaskRequestModel({
    required this.taskName,
    this.taskDescription,
    this.taskDueDate,
    this.taskPriority,
    this.estimateDurationMinutes,
    super.args,
  }) : super(actionRequestType: AiActionRequestType.createTask);

  static CreateTaskRequestModel fromJson(Map<String, dynamic> json) {
    return CreateTaskRequestModel(
      args: json['args'],
      taskName: json['args']['task_name'],
      taskDescription: json['args']['task_description'],
      taskDueDate: json['args']['task_due_date'],
      taskPriority: json['args']['task_priority'],
      estimateDurationMinutes: json['args']['estimate_duration_minutes'],
    );
  }
}

class UpdateTaskFieldsRequestModel extends AiActionRequestModel {
  final String taskName;
  final String? taskDescription;
  final String? taskDueDate;
  final String? taskStatus;
  final String? taskPriority;
  final int? estimateDurationMinutes;

  UpdateTaskFieldsRequestModel({
    required this.taskName,
    this.taskDescription,
    this.taskDueDate,
    this.taskStatus,
    this.taskPriority,
    this.estimateDurationMinutes,
    super.args,
  }) : super(actionRequestType: AiActionRequestType.updateTaskFields);

  static UpdateTaskFieldsRequestModel fromJson(Map<String, dynamic> json) {
    return UpdateTaskFieldsRequestModel(
      args: json['args'],
      taskName: json['args']['task_name'],
      taskDescription: json['args']['task_description'],
      taskDueDate: json['args']['task_due_date'],
      taskStatus: json['args']['task_status'],
      taskPriority: json['args']['task_priority'],
      estimateDurationMinutes: json['args']['estimate_duration_minutes'],
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