import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';
import 'package:seren_ai_flutter/services/notifications/models/push_notification_model.dart';
import 'package:seren_ai_flutter/services/notifications/repositories/push_notifications_repository.dart';

/// Stream provider for push notifications sent (or scheduled) to the current user
final curUserPushNotificationsProvider =
    StreamProvider.autoDispose<List<PushNotificationModel>>(
  (ref) {
    final pushNotificationsRepo =
        ref.watch(pushNotificationsRepositoryProvider);

    return CurAuthDependencyProvider.watchStream(
      ref: ref,
      builder: (userId) {
        return pushNotificationsRepo.watchPushNotificationsForUser(userId);
      },
    );
  },
);
