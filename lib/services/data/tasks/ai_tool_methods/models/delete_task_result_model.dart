import 'package:seren_ai_flutter/services/ai/ai_request/models/results/ai_request_result_model.dart';

class DeleteTaskResultModel extends AiRequestResultModel {
  DeleteTaskResultModel({
    required super.resultForAi,
    required this.isDeleted,
    required this.taskName,
  }) : super(resultType: AiRequestResultType.deleteTask);

  // TODO: remove nullability (supposed to be not null in the backend)
  final bool? isDeleted;
  final String? taskName;

  factory DeleteTaskResultModel.fromJson(Map<String, dynamic> json) {
    return DeleteTaskResultModel(
      resultForAi: json['result_for_ai'],
      isDeleted: json['is_deleted'],
      taskName: json['task_name'],
    );
  }
}
