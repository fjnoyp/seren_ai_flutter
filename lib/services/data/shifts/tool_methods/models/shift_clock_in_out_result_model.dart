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
      clockedIn: json['clocked_in'],
      resultForAi: json['result_for_ai'],
      showOnly: json['show_only'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toJson()..addAll({
      'clocked_in': clockedIn,
    });
  }
}
