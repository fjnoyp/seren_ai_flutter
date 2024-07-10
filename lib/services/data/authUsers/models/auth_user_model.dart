import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/i_has_id.dart';

part 'auth_user_model.g.dart';

@JsonSerializable()
class AuthUserModel implements IHasId {
  @override
  final String id;
  final String? email;

  AuthUserModel({
    required this.id,
    this.email,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) => _$AuthUserModelFromJson(json);
  Map<String, dynamic> toJson() => _$AuthUserModelToJson(this);
}