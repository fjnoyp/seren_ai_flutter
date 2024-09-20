import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'shift_log_model.g.dart';

@JsonSerializable()
class ShiftLogModel implements IHasId {
  @override
  final String id;
  
  @JsonKey(name: 'user_id')
  final String userId;
  
  @JsonKey(name: 'shift_id')
  final String shiftId;
  
  @JsonKey(name: 'clock_in_datetime')
  final DateTime clockInDatetime;
  
  @JsonKey(name: 'clock_out_datetime')
  final DateTime? clockOutDatetime;
  
  @JsonKey(name: 'is_break', fromJson: _boolFromInt)
  final bool isBreak;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  static bool _boolFromInt(dynamic value) => value == 1;

  ShiftLogModel({
    String? id,
    required this.userId,
    required this.shiftId,
    required this.clockInDatetime,
    this.clockOutDatetime,
    required this.isBreak,
    this.createdAt,
    this.updatedAt,
  }) : id = id ?? uuid.v4();

  ShiftLogModel copyWith({
    String? id,
    String? userId,
    String? shiftId,
    DateTime? clockInDatetime,
    DateTime? clockOutDatetime,
    bool? isBreak,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShiftLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shiftId: shiftId ?? this.shiftId,
      clockInDatetime: clockInDatetime ?? this.clockInDatetime,
      clockOutDatetime: clockOutDatetime ?? this.clockOutDatetime,
      isBreak: isBreak ?? this.isBreak,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ShiftLogModel.fromJson(Map<String, dynamic> json) => _$ShiftLogModelFromJson(json);
  Map<String, dynamic> toJson() => _$ShiftLogModelToJson(this);
}