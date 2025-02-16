import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';

part 'device_token_model.g.dart';

@JsonSerializable()
class DeviceTokenModel implements IHasId {
  @override
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'device_id')
  final String deviceId;
  @JsonKey(name: 'fcm_token')
  final String fcmToken;

  @JsonKey(name: 'device_model')
  final String? deviceModel;
  final String platform;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'last_used_at')
  final DateTime lastUsedAt;
  @JsonKey(name: 'is_active')
  final bool isActive;

  DeviceTokenModel({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.fcmToken,
    this.deviceModel,
    required this.platform,
    required this.createdAt,
    required this.updatedAt,
    required this.lastUsedAt,
    required this.isActive,
  });

  factory DeviceTokenModel.fromJson(Map<String, dynamic> json) =>
      _$DeviceTokenModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceTokenModelToJson(this);
}
