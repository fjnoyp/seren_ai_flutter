import 'dart:convert';

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

  factory PushNotificationModel.fromJson(Map<String, dynamic> json) {
    try {
      // when using supabase directly, the json is properly decoded
      return _$PushNotificationModelFromJson(json);
    } catch (e) {
      // when using powersync, the json types mismatch
      // (List and Map => String, bool => int)
      // so we need to decode it manually
      final decodedJson = json.map((key, value) => switch (key) {
            'user_ids' => MapEntry(key, jsonDecode(value).cast<String>()),
            'data' => MapEntry(key, jsonDecode(value)),
            'is_sent' => MapEntry(key, value == 1),
            _ => MapEntry(key, value),
          });

      return _$PushNotificationModelFromJson(decodedJson);
    }
  }

  @override
  Map<String, dynamic> toJson() => _$PushNotificationModelToJson(this);

  // when using powersync, the json need to be properly encoded (manually).
  // just need to find a way to apply this conditionally to the toJson method
  // for now, we're not using powersync's insertion method
  //
  // json.map((key, value) => switch (key) {
  //       'user_ids' => MapEntry(key, jsonEncode(value)),
  //       'data' => MapEntry(key, jsonEncode(value.toJson())),
  //       'is_sent' => MapEntry(key, value ? 1 : 0),
  //       _ => MapEntry(key, value),
  //     });
}
