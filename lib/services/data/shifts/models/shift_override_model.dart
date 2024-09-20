import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/json_parsing.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'shift_override_model.g.dart';

@JsonSerializable()
class ShiftOverrideModel implements IHasId {
  @override
  final String id;
  
  @JsonKey(name: 'user_id')
  final String? userId;
  
  @JsonKey(name: 'shift_id')
  final String shiftId;
  
  @JsonKey(name: 'start_datetime')
  final DateTime startDatetime;
  
  @JsonKey(name: 'end_datetime')
  final DateTime endDatetime;
  
  @JsonKey(name: 'is_removal', fromJson: boolFromInt, toJson: boolToInt)
  final bool isRemoval;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  ShiftOverrideModel({
    String? id,
    this.userId,
    required this.shiftId,
    required this.startDatetime,
    required this.endDatetime,
    this.isRemoval = false,
    this.createdAt,
    this.updatedAt,
  }) : id = id ?? uuid.v4();
  ShiftOverrideModel copyWith({
    String? id,
    String? userId,
    String? shiftId,
    DateTime? startDatetime,
    DateTime? endDatetime,
    bool? isRemoval,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShiftOverrideModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shiftId: shiftId ?? this.shiftId,
      startDatetime: startDatetime ?? this.startDatetime,
      endDatetime: endDatetime ?? this.endDatetime,
      isRemoval: isRemoval ?? this.isRemoval,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ShiftOverrideModel.fromJson(Map<String, dynamic> json) => _$ShiftOverrideModelFromJson(json);
  Map<String, dynamic> toJson() => _$ShiftOverrideModelToJson(this);
}