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

  OrgModel({
    String? id,
    required this.name,
    this.address,
  }) : id = id ?? uuid.v4();

  factory OrgModel.fromJson(Map<String, dynamic> json) => _$OrgModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrgModelToJson(this);
}
