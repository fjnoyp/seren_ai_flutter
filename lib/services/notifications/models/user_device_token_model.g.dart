// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_device_token_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDeviceTokenModel _$UserDeviceTokenModelFromJson(
        Map<String, dynamic> json) =>
    UserDeviceTokenModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      deviceId: json['device_id'] as String,
      fcmToken: json['fcm_token'] as String,
      deviceModel: json['device_model'] as String?,
      platform: json['platform'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$UserDeviceTokenModelToJson(
        UserDeviceTokenModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'device_id': instance.deviceId,
      'fcm_token': instance.fcmToken,
      'device_model': instance.deviceModel,
      'platform': instance.platform,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
