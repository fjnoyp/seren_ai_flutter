import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/ai_request_result_model.dart';

class ErrorRequestResultModel extends AiRequestResultModel {
  ErrorRequestResultModel({required super.resultForAi, required super.showOnly}) : super(resultType: AiRequestResultType.error);
}
