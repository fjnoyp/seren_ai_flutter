import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

class FindTasksResultModel extends AiRequestResultModel {
  final List<TaskModel> tasks;

  FindTasksResultModel(
      {required this.tasks,
      required super.resultForAi,
      required super.showOnly})
      : super(resultType: AiRequestResultType.findTasks);

  factory FindTasksResultModel.fromJson(Map<String, dynamic> json) {
    return FindTasksResultModel(
      tasks: (json['tasks'] as List)
          // Adjustment to fit old and new data structures
          .map((task) => TaskModel.fromJson(task['task'] ?? task))
          .toList(),
      resultForAi: json['result_for_ai'],
      showOnly: json['show_only'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toJson()
      ..addAll({
        'tasks': tasks.map((task) => task.toJson()).toList(),
      });
  }
}
