import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/json_parsing.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'shift_timeframe_model.g.dart';

@JsonSerializable()
class ShiftTimeframeModel implements IHasId {
  @override
  final String id;
  
  @JsonKey(name: 'shift_id')
  final String shiftId;
  
  @JsonKey(name: 'day_of_week')
  final int dayOfWeek;
  
  @JsonKey(name: 'start_time')
  final String startTime;
  
  @JsonKey(name: 'duration', fromJson: parseDuration, toJson: durationToString)
  final Duration duration;
  
  final String timezone;

  ShiftTimeframeModel({
    String? id,
    required this.shiftId,
    required this.dayOfWeek,
    required this.startTime,
    required this.duration,
    required this.timezone,
  }) : id = id ?? uuid.v4();

  ShiftTimeframeModel copyWith({
    String? id,
    String? shiftId,
    int? dayOfWeek,
    String? startTime,
    Duration? duration,
    String? timezone,
  }) {
    return ShiftTimeframeModel(
      id: id ?? this.id,
      shiftId: shiftId ?? this.shiftId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      timezone: timezone ?? this.timezone,
    );
  }

  factory ShiftTimeframeModel.fromJson(Map<String, dynamic> json) => _$ShiftTimeframeModelFromJson(json);
  Map<String, dynamic> toJson() => _$ShiftTimeframeModelToJson(this);
}