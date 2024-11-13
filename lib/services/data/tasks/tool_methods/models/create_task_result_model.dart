import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';

class CreateTaskResultModel extends AiRequestResultModel {
  final JoinedTaskModel joinedTask;

  CreateTaskResultModel({
    required this.joinedTask, 
    required super.resultForAi, 
    required super.showOnly
  }) : super(resultType: AiRequestResultType.createTask);

  factory CreateTaskResultModel.fromJson(Map<String, dynamic> json) {
    return CreateTaskResultModel(
      joinedTask: JoinedTaskModel.fromJson(json['joined_task']),
      resultForAi: json['result_for_ai'],
      showOnly: json['show_only'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toJson()..addAll({
      'joined_task': joinedTask.toJson(),
    });
  }
}