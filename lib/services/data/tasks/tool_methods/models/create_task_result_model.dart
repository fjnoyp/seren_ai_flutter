import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

class CreateTaskResultModel extends AiRequestResultModel {
  final TaskModel task;

  CreateTaskResultModel(
      {required this.task, required super.resultForAi, required super.showOnly})
      : super(resultType: AiRequestResultType.createTask);

  factory CreateTaskResultModel.fromJson(Map<String, dynamic> json) {
    return CreateTaskResultModel(
      task: TaskModel.fromJson(json['task']),
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
