import 'package:seren_ai_flutter/services/ai/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_comment_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

class AddCommentToTaskResultModel extends AiRequestResultModel {
  final TaskModel? task;
  final TaskCommentModel comment;

  AddCommentToTaskResultModel({
    required this.comment,
    this.task,
    required super.resultForAi,
  }) : super(resultType: AiRequestResultType.addCommentToTask);

  factory AddCommentToTaskResultModel.fromJson(Map<String, dynamic> json) {
    return AddCommentToTaskResultModel(
      comment: TaskCommentModel.fromJson(json['comment']),
      task: json['task'] != null ? TaskModel.fromJson(json['task']) : null,
      resultForAi: json['result_for_ai'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['comment'] = comment.toJson();
    if (task != null) {
      json['task'] = task!.toJson();
    }
    return json;
  }
}
