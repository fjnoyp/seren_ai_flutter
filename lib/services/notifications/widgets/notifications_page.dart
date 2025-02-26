import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/notifications/models/push_notification_model.dart';
import 'package:seren_ai_flutter/services/notifications/notification_history/providers/cur_user_push_notifications_provider.dart';
import 'package:seren_ai_flutter/services/notifications/services/notification_data_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
          child: AsyncValueHandlerWidget(
            value: ref.watch(curUserPushNotificationsProvider),
            data: (notifications) => notifications.isEmpty
                ? Center(child: Text(AppLocalizations.of(context)!.noNotificationsFound))
                : ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return NotificationListTile(notification: notification);
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class NotificationListTile extends ConsumerWidget {
  final PushNotificationModel notification;

  const NotificationListTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(notification.notificationTitle),
      subtitle: Text(notification.notificationBody,
          maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right),
      onTap: notification.data != null
          ? () => NotificationDataHandler.handleNotificationOpen(
                notification.data!,
                ref,
              )
          : null,
    );
  }
}
