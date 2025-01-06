import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

class UpdateTaskFieldsResultModel extends AiRequestResultModel {
  final TaskModel task;

  UpdateTaskFieldsResultModel(
      {required this.task, required super.resultForAi, required super.showOnly})
      : super(resultType: AiRequestResultType.updateTaskFields);

  factory UpdateTaskFieldsResultModel.fromJson(Map<String, dynamic> json) {
    return UpdateTaskFieldsResultModel(
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
