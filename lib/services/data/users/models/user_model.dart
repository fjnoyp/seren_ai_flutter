import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel implements IHasId {
  @override
  final String id;

  @JsonKey(name: 'parent_auth_user_id')
  final String parentAuthUserId; 
  final String? email;

  UserModel({
    required this.id,
    required this.parentAuthUserId,
    this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}