import 'package:seren_ai_flutter/services/ai/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/ai_tool_methods/models/task_request_models.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

class FindTasksResultModel extends AiRequestResultModel {
  final List<TaskModel> tasks;
  final Map<String, dynamic> searchCriteria;

  FindTasksResultModel(
      {required this.tasks,
      required super.resultForAi,
      required super.showOnly,
      this.searchCriteria = const {}})
      : super(resultType: AiRequestResultType.findTasks);

  /// Factory constructor that processes the search criteria from the request
  factory FindTasksResultModel.fromTasksAndRequest({
    required List<TaskModel> tasks,
    required FindTasksRequestModel request,
    required String resultForAi,
    required bool showOnly,
  }) {
    final searchCriteria = _processSearchCriteria(request);

    return FindTasksResultModel(
      tasks: tasks,
      resultForAi: resultForAi,
      showOnly: showOnly,
      searchCriteria: searchCriteria,
    );
  }

  /// Process search criteria from the request
  static Map<String, dynamic> _processSearchCriteria(
      FindTasksRequestModel request) {
    final Map<String, dynamic> searchCriteria = {};

    if (request.taskName != null) {
      searchCriteria['name'] = request.taskName;
    }
    if (request.taskDescription != null) {
      searchCriteria['description'] = request.taskDescription;
    }
    if (request.taskStatus != null) {
      searchCriteria['status'] = request.taskStatus;
    }
    if (request.taskPriority != null) {
      searchCriteria['priority'] = request.taskPriority;
    }
    if (request.assignedUserNames != null) {
      searchCriteria['assignees'] = request.assignedUserNames;
    }
    if (request.authorUserName != null) {
      searchCriteria['author'] = request.authorUserName;
    }
    if (request.parentProjectName != null) {
      searchCriteria['project'] = request.parentProjectName;
    }
    if (request.taskDueDateStart != null || request.taskDueDateEnd != null) {
      searchCriteria['dueDate'] = {};
      if (request.taskDueDateStart != null) {
        searchCriteria['dueDate']['from'] = request.taskDueDateStart;
      }
      if (request.taskDueDateEnd != null) {
        searchCriteria['dueDate']['to'] = request.taskDueDateEnd;
      }
    }
    if (request.taskCreatedDateStart != null ||
        request.taskCreatedDateEnd != null) {
      searchCriteria['createdDate'] = {};
      if (request.taskCreatedDateStart != null) {
        searchCriteria['createdDate']['from'] = request.taskCreatedDateStart;
      }
      if (request.taskCreatedDateEnd != null) {
        searchCriteria['createdDate']['to'] = request.taskCreatedDateEnd;
      }
    }
    if (request.taskUpdatedDateStart != null ||
        request.taskUpdatedDateEnd != null) {
      searchCriteria['updatedDate'] = {};
      if (request.taskUpdatedDateStart != null) {
        searchCriteria['updatedDate']['from'] = request.taskUpdatedDateStart;
      }
      if (request.taskUpdatedDateEnd != null) {
        searchCriteria['updatedDate']['to'] = request.taskUpdatedDateEnd;
      }
    }

    return searchCriteria;
  }

  factory FindTasksResultModel.fromJson(Map<String, dynamic> json) {
    return FindTasksResultModel(
      tasks: (json['tasks'] as List)
          // Adjustment to fit old and new data structures
          .map((task) => TaskModel.fromJson(task['task'] ?? task))
          .toList(),
      resultForAi: json['result_for_ai'],
      showOnly: json['show_only'],
      searchCriteria: json['search_criteria'] ?? {},
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toJson()
      ..addAll({
        'tasks': tasks.map((task) => task.toJson()).toList(),
        'search_criteria': searchCriteria,
      });
  }
}
