import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';

class CreateTaskResultModel extends AiRequestResultModel {
  final TaskModel task;
  final List<SearchUserResult>? userAssignmentResults;

  CreateTaskResultModel(
      {required this.task,
      required super.resultForAi,
      required super.showOnly,
      this.userAssignmentResults})
      : super(resultType: AiRequestResultType.createTask);

  factory CreateTaskResultModel.fromJson(Map<String, dynamic> json) {
    return CreateTaskResultModel(
      // Adjustment to fit old and new data structures
      task: TaskModel.fromJson(json['task'] ?? json['joined_task']['task']),
      resultForAi: json['result_for_ai'],
      showOnly: json['show_only'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toJson()
      ..addAll({
        'task': task.toJson(),
      });
  }
}
