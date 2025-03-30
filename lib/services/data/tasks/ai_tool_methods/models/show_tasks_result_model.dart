import 'package:seren_ai_flutter/services/ai/ai_request/models/results/ai_request_result_model.dart';

class ShowTasksResultModel extends AiRequestResultModel {
  ShowTasksResultModel({
    required String resultForAi,
    required bool showOnly,
  }) : super(
            resultType: AiRequestResultType.showTasks,
            resultForAi: resultForAi,
            showOnly: showOnly);

  factory ShowTasksResultModel.fromJson(Map<String, dynamic> json) {
    return ShowTasksResultModel(
      resultForAi: json['result_for_ai'],
      showOnly: json['show_only'],
    );
  }
}
