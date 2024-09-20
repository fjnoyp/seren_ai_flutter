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
  
  @JsonKey(name: 'parent_team_id')
  final String? parentTeamId;
  
  @JsonKey(name: 'parent_project_id')
  final String parentProjectId;

  ShiftModel({
    String? id,
    required this.name,
    required this.authorUserId,
    this.parentTeamId,
    required this.parentProjectId,
  }) : id = id ?? uuid.v4();

  factory ShiftModel.defaultShift() {
    return ShiftModel(
      name: 'New Shift',
      authorUserId: '',
      parentProjectId: '',
    );
  }

  ShiftModel copyWith({
    String? id,
    String? name,
    String? authorUserId,
    String? parentTeamId,
    String? parentProjectId,
  }) {
    return ShiftModel(
      id: id ?? this.id,
      name: name ?? this.name,
      authorUserId: authorUserId ?? this.authorUserId,
      parentTeamId: parentTeamId ?? this.parentTeamId,
      parentProjectId: parentProjectId ?? this.parentProjectId,
    );
  }

  factory ShiftModel.fromJson(Map<String, dynamic> json) => _$ShiftModelFromJson(json);
  Map<String, dynamic> toJson() => _$ShiftModelToJson(this);
}