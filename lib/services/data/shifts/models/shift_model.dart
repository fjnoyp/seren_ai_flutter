import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'shift_model.g.dart';

@JsonSerializable()
class ShiftModel implements IHasId {
  @override
  final String id;
  final String name;
  
  @JsonKey(name: 'author_user_id')
  final String authorUserId;
  
  @JsonKey(name: 'parent_project_id')
  final String parentProjectId;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  ShiftModel({
    String? id,
    required this.name,
    required this.authorUserId,
    required this.parentProjectId,
    this.createdAt,
    this.updatedAt,
  }) : id = id ?? uuid.v4();

  factory ShiftModel.defaultShift() {
    final now = DateTime.now().toUtc();
    return ShiftModel(
      name: 'New Shift',
      authorUserId: '',
      parentProjectId: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  ShiftModel copyWith({
    String? id,
    String? name,
    String? authorUserId,
    String? parentProjectId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShiftModel(
      id: id ?? this.id,
      name: name ?? this.name,
      authorUserId: authorUserId ?? this.authorUserId,
      parentProjectId: parentProjectId ?? this.parentProjectId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ShiftModel.fromJson(Map<String, dynamic> json) => _$ShiftModelFromJson(json);
  Map<String, dynamic> toJson() => _$ShiftModelToJson(this);
}