import 'package:json_annotation/json_annotation.dart';

import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';
import 'package:seren_ai_flutter/services/notifications/models/notification_data.dart';

part 'push_notification_model.g.dart';

@JsonSerializable()
class PushNotificationModel extends IHasId {
  @override
  final String id;

  @JsonKey(name: 'user_ids')
  final List<String> userIds;

  @JsonKey(name: 'reference_id')
  final String referenceId;

  @JsonKey(name: 'reference_type')
  final String referenceType;

  @JsonKey(name: 'notification_title')
  final String notificationTitle;

  @JsonKey(name: 'notification_body')
  final String notificationBody;

  @JsonKey(fromJson: _dataFromJson, toJson: _dataToJson)
  final NotificationData? data;

  static NotificationData? _dataFromJson(Map<String, dynamic> json) =>
      NotificationData.fromJson(json);

  static Map<String, dynamic> _dataToJson(NotificationData? data) =>
      data?.toJson() ?? {};

  @JsonKey(name: 'send_at')
  final DateTime sendAt;

  @JsonKey(name: 'is_sent')
  final bool isSent;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  PushNotificationModel({
    String? id,
    required this.userIds,
    required this.referenceId,
    required this.referenceType,
    required this.notificationTitle,
    required this.notificationBody,
    this.data,
    required DateTime sendAt,
    this.isSent = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? uuid.v4(),
        sendAt = sendAt.toLocal(),
        createdAt = createdAt?.toLocal(),
        updatedAt = updatedAt?.toLocal();

  factory PushNotificationModel.fromJson(Map<String, dynamic> json) =>
      _$PushNotificationModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PushNotificationModelToJson(this);
}
