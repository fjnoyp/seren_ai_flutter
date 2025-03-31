import 'package:seren_ai_flutter/services/ai/ai_request/models/results/ai_request_result_model.dart';

class ErrorRequestResultModel extends AiRequestResultModel {
  ErrorRequestResultModel({required super.resultForAi})
      : super(resultType: AiRequestResultType.error);

  static ErrorRequestResultModel fromJson(Map<String, dynamic> json) {
    return ErrorRequestResultModel(
      resultForAi: json['result_for_ai'],
    );
  }
}
