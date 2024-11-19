import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/ai_request_result_model.dart';

class DeleteTaskResultModel extends AiRequestResultModel {
  DeleteTaskResultModel({
    required super.resultForAi,
    required super.showOnly,
  }) : super(resultType: AiRequestResultType.deleteTask);

  factory DeleteTaskResultModel.fromJson(Map<String, dynamic> json) {
    return DeleteTaskResultModel(
      resultForAi: json['result_for_ai'],
      showOnly: json['show_only'],
    );
  }
}
