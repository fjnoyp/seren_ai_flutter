import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'user_device_token_model.g.dart';

@JsonSerializable()
class UserDeviceTokenModel implements IHasId {
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
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  UserDeviceTokenModel({
    String? id,
    required this.userId,
    required this.deviceId,
    required this.fcmToken,
    this.deviceModel,
    required this.platform,
    this.createdAt,
    this.updatedAt,
  }) : id = id ?? uuid.v4();

  factory UserDeviceTokenModel.fromJson(Map<String, dynamic> json) =>
      _$UserDeviceTokenModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserDeviceTokenModelToJson(this);

  UserDeviceTokenModel copyWith({
    String? id,
    String? userId,
    String? deviceId,
    String? fcmToken,
    String? deviceModel,
    String? platform,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserDeviceTokenModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      fcmToken: fcmToken ?? this.fcmToken,
      deviceModel: deviceModel ?? this.deviceModel,
      platform: platform ?? this.platform,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
