import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/utils/json_parsing.dart';
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

  //final String timezone;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  ShiftTimeframeModel({
    String? id,
    required this.shiftId,
    required this.dayOfWeek,
    required this.startTime,
    required this.duration,
    //required this.timezone,
    this.createdAt,
    this.updatedAt,
  }) : id = id ?? uuid.v4();

  ShiftTimeframeModel copyWith({
    String? id,
    String? shiftId,
    int? dayOfWeek,
    String? startTime,
    Duration? duration,
    //String? timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShiftTimeframeModel(
      id: id ?? this.id,
      shiftId: shiftId ?? this.shiftId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      //timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ShiftTimeframeModel.fromJson(Map<String, dynamic> json) =>
      _$ShiftTimeframeModelFromJson(json);
  Map<String, dynamic> toJson() => _$ShiftTimeframeModelToJson(this);

  /// UTC only 
  DateTime getStartDateTime(DateTime day) {
    assert(day.isUtc, 'ShiftTimeframeModel: input day is not in UTC');

    // Parse the startTime string
    List<String> timeParts = startTime.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    assert(startTime.contains('+00'),
        'ShiftTimeframeModel: startTime is not in UTC');

    // Create a DateTime in UTC for the given day
    DateTime utcDateTime = DateTime.utc(
      day.year,
      day.month,
      day.day,
      hour,
      minute,
    );

    return utcDateTime;
  }

  DateTime getEndDateTime(DateTime day) {
    DateTime start = getStartDateTime(day);

    // Add the duration to the start time
    return start.add(duration);
  }
}
