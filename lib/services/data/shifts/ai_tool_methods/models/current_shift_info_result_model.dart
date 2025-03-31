import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_model.dart';

class CurrentShiftInfoResultModel extends AiRequestResultModel {
  final bool isUserClockedIn;
  final DateTime? clockInTime;
  final int? curShiftDurationMinutes;
  final List<DateTimeRange> todayAssignments;
  final ShiftModel? shift;

  CurrentShiftInfoResultModel({
    required this.isUserClockedIn,
    required this.clockInTime,
    required this.curShiftDurationMinutes,
    required this.todayAssignments,
    required this.shift,
    required super.resultForAi,
  }) : super(resultType: AiRequestResultType.currentShiftInfo);

  factory CurrentShiftInfoResultModel.fromJson(Map<String, dynamic> json) {
    return CurrentShiftInfoResultModel(
      isUserClockedIn: json['is_user_clocked_in'] ?? false,
      clockInTime: json['clock_in_time'] != null
          ? DateTime.parse(json['clock_in_time'])
          : null,
      curShiftDurationMinutes: json['cur_shift_duration_minutes'],
      todayAssignments: (json['today_assignments'] as List?)
              ?.map((range) => DateTimeRange(
                    start: DateTime.parse(range['start']),
                    end: DateTime.parse(range['end']),
                  ))
              .toList() ??
          [],
      shift: json['shift'] != null ? ShiftModel.fromJson(json['shift']) : null,
      resultForAi: json['result_for_ai'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toJson()
      ..addAll({
        'is_user_clocked_in': isUserClockedIn,
        'clock_in_time': clockInTime?.toIso8601String(),
        'cur_shift_duration_minutes': curShiftDurationMinutes,
        'today_assignments': todayAssignments
            .map((range) => {
                  'start': range.start.toIso8601String(),
                  'end': range.end.toIso8601String(),
                })
            .toList(),
        'shift': shift?.toJson(),
      });
  }
}
