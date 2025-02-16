// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_token_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceTokenModel _$DeviceTokenModelFromJson(Map<String, dynamic> json) =>
    DeviceTokenModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      deviceId: json['device_id'] as String,
      fcmToken: json['fcm_token'] as String,
      deviceModel: json['device_model'] as String?,
      platform: json['platform'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastUsedAt: DateTime.parse(json['last_used_at'] as String),
      isActive: json['is_active'] as bool,
    );

Map<String, dynamic> _$DeviceTokenModelToJson(DeviceTokenModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'device_id': instance.deviceId,
      'fcm_token': instance.fcmToken,
      'device_model': instance.deviceModel,
      'platform': instance.platform,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'last_used_at': instance.lastUsedAt.toIso8601String(),
      'is_active': instance.isActive,
    };
