import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';

class FindTasksResultModel extends AiRequestResultModel {
  final List<JoinedTaskModel> tasks;

  FindTasksResultModel({required this.tasks, required super.resultForAi, required super.showOnly}) : super(resultType: AiRequestResultType.findTasks);

  factory FindTasksResultModel.fromJson(Map<String, dynamic> json) {
    return FindTasksResultModel(
      tasks: (json['tasks'] as List)
          .map((task) => JoinedTaskModel.fromJson(task))
          .toList(),
      resultForAi: json['result_for_ai'],
      showOnly: json['show_only'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toJson()..addAll({
      'tasks': tasks.map((task) => task.toJson()).toList(),
    });
  }
}