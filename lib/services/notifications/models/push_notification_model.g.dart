// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushNotificationModel _$PushNotificationModelFromJson(
        Map<String, dynamic> json) =>
    PushNotificationModel(
      id: json['id'] as String?,
      userIds:
          (json['user_ids'] as List<dynamic>).map((e) => e as String).toList(),
      referenceId: json['reference_id'] as String,
      referenceType: json['reference_type'] as String,
      notificationTitle: json['notification_title'] as String,
      notificationBody: json['notification_body'] as String,
      data: PushNotificationModel._dataFromJson(
          json['data'] as Map<String, dynamic>),
      sendAt: DateTime.parse(json['send_at'] as String),
      isSent: json['is_sent'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$PushNotificationModelToJson(
        PushNotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_ids': instance.userIds,
      'reference_id': instance.referenceId,
      'reference_type': instance.referenceType,
      'notification_title': instance.notificationTitle,
      'notification_body': instance.notificationBody,
      'data': PushNotificationModel._dataToJson(instance.data),
      'send_at': instance.sendAt.toIso8601String(),
      'is_sent': instance.isSent,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
