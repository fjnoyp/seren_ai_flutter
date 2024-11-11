import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/ai_request_executor.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/ai_request_result_model.dart';

class ShiftClockInOutResultModel extends AiRequestResultModel {
  final bool clockedIn;

  ShiftClockInOutResultModel({
    required this.clockedIn,
    required super.resultForAi,
    required super.showOnly,
  }) : super(resultType: AiRequestResultType.shiftClockInOut);

  factory ShiftClockInOutResultModel.fromJson(Map<String, dynamic> json) {
    return ShiftClockInOutResultModel(
      clockedIn: json['clockedIn'],
      resultForAi: json['resultForAi'],
      showOnly: json['showOnly'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toJson()..addAll({
      'clockedIn': clockedIn,
    });
  }
}
