import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'org_model.g.dart';

@JsonSerializable()
class OrgModel implements IHasId {
  @override
  final String id;
  final String name;
  final String? address;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  OrgModel({
    String? id,
    required this.name,
    this.address,
    this.createdAt,
    this.updatedAt,
  }) : id = id ?? uuid.v4();

  factory OrgModel.fromJson(Map<String, dynamic> json) => _$OrgModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrgModelToJson(this);

  OrgModel copyWith({
    String? id,
    String? name,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrgModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
