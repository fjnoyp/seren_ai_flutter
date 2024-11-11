import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/ai_request_executor.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/ai_request_result_model.dart';
class ShiftAssignmentsResultModel extends AiRequestResultModel {
  final Map<DateTime, List<DateTimeRange>> shiftAssignments;

  ShiftAssignmentsResultModel({
    required this.shiftAssignments,
    required super.resultForAi,
    required super.showOnly,
  }) : super(resultType: AiRequestResultType.shiftAssignments);

  factory ShiftAssignmentsResultModel.fromJson(Map<String, dynamic> json) {
    return ShiftAssignmentsResultModel(
      shiftAssignments: (json['shiftAssignments'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(
                DateTime.parse(key),
                (value as List)
                    .map((range) => DateTimeRange(
                          start: DateTime.parse(range['start']),
                          end: DateTime.parse(range['end']),
                        ))
                    .toList(),
              )),
      resultForAi: json['resultForAi'],
      showOnly: json['showOnly'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toJson()..addAll({
      'shiftAssignments': shiftAssignments.map((key, value) => MapEntry(
        key.toIso8601String(),
        value.map((range) => {
          'start': range.start.toIso8601String(),
          'end': range.end.toIso8601String(),
        }).toList(),
      )),
    });
  }
}