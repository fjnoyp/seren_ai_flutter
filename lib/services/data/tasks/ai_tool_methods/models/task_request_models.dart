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
  final String? taskUpdatedDateStart;
  final String? taskUpdatedDateEnd;
  final bool showToUser;

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
    this.taskUpdatedDateStart,
    this.taskUpdatedDateEnd,
    this.showToUser = true,
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
      taskUpdatedDateStart: json['args']['task_updated_date_start'],
      taskUpdatedDateEnd: json['args']['task_updated_date_end'],
      showToUser: json['args']['show_to_user'] ?? true,
    );
  }
}

class ShowTasksRequestModel extends AiActionRequestModel {
  final String? taskId;
  final String? taskName;
  final String? parentProjectName;
  final TaskViewType taskType;
  final bool showToUser;

  ShowTasksRequestModel({
    this.taskId,
    this.taskName,
    this.parentProjectName,
    required this.taskType,
    this.showToUser = true,
    super.args,
  }) : super(actionRequestType: AiActionRequestType.showTasks);

  static ShowTasksRequestModel fromJson(Map<String, dynamic> json) {
    final taskTypeStr = json['args']['task_type'];
    return ShowTasksRequestModel(
      args: json['args'],
      taskId: json['args']['task_id'],
      taskName: json['args']['task_name'],
      parentProjectName: json['args']['parent_project_name'],
      taskType: TaskViewType.fromString(taskTypeStr),
      showToUser: json['args']['show_to_user'] ?? true,
    );
  }
}

enum TaskViewType {
  singleTask,
  recentTasks,
  myTasks,
  projectGanttTasks,
  projectTasks;

  static TaskViewType fromString(String value) {
    return TaskViewType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => TaskViewType.singleTask,
    );
  }
}

class AddCommentToTaskRequestModel extends AiActionRequestModel {
  final String taskId;
  final String taskName;
  final String comment;
  final bool showToUser;

  AddCommentToTaskRequestModel({
    required this.taskId,
    required this.taskName,
    required this.comment,
    this.showToUser = true,
    super.args,
  }) : super(actionRequestType: AiActionRequestType.addCommentToTask);

  static AddCommentToTaskRequestModel fromJson(Map<String, dynamic> json) {
    return AddCommentToTaskRequestModel(
      args: json['args'],
      taskId: json['args']['task_id'],
      taskName: json['args']['task_name'],
      comment: json['args']['comment'],
      showToUser: json['args']['show_to_user'] ?? true,
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
  final bool showToUser;

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
    this.showToUser = true,
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
      showToUser: json['args']['show_to_user'] ?? true,
    );
  }
}

class UpdateTaskFieldsRequestModel extends AiActionRequestModel {
  final String taskId;
  final String taskName;
  final String? taskDescription;
  final String? taskStartDate;
  final String? taskDueDate;
  final String? taskStatus;
  final String? taskPriority;
  final int? estimateDurationMinutes;
  final List<String>? assignedUserNames;
  final String? parentProjectName;
  final bool showToUser;

  UpdateTaskFieldsRequestModel({
    required this.taskId,
    required this.taskName,
    this.taskDescription,
    this.taskStartDate,
    this.taskDueDate,
    this.taskStatus,
    this.taskPriority,
    this.estimateDurationMinutes,
    this.assignedUserNames,
    this.parentProjectName,
    this.showToUser = true,
    super.args,
  }) : super(actionRequestType: AiActionRequestType.updateTaskFields);

  static UpdateTaskFieldsRequestModel fromJson(Map<String, dynamic> json) {
    return UpdateTaskFieldsRequestModel(
      args: json['args'],
      taskId: json['args']['task_id'],
      taskName: json['args']['task_name'],
      taskDescription: json['args']['task_description'],
      taskStartDate: json['args']['task_start_date'],
      taskDueDate: json['args']['task_due_date'],
      taskStatus: json['args']['task_status'],
      taskPriority: json['args']['task_priority'],
      estimateDurationMinutes: json['args']['estimate_duration_minutes'],
      assignedUserNames: json['args']['assigned_user_names']?.cast<String>(),
      parentProjectName: json['args']['parent_project_name'],
      showToUser: json['args']['show_to_user'] ?? true,
    );
  }
}

class DeleteTaskRequestModel extends AiActionRequestModel {
  final String taskId;
  final String taskName;
  final bool showToUser;

  DeleteTaskRequestModel({
    required this.taskId,
    required this.taskName,
    this.showToUser = true,
    super.args,
  }) : super(actionRequestType: AiActionRequestType.deleteTask);

  static DeleteTaskRequestModel fromJson(Map<String, dynamic> json) {
    return DeleteTaskRequestModel(
      args: json['args'],
      taskId: json['args']['task_id'],
      taskName: json['args']['task_name'],
      showToUser: json['args']['show_to_user'] ?? true,
    );
  }
}
