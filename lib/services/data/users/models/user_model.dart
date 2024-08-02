import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel implements IHasId {
  @override
  final String id;

  @JsonKey(name: 'parent_auth_user_id')
  final String parentAuthUserId; 
  final String email;

  UserModel({
    String? id,
    required this.parentAuthUserId,
    required this.email,
  }) : id = id ?? uuid.v4();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}