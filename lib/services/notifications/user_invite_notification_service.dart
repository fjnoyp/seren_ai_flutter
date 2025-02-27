import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';
import 'package:seren_ai_flutter/services/notifications/models/notification_data.dart';
import 'package:seren_ai_flutter/services/notifications/models/push_notification_model.dart';
import 'package:seren_ai_flutter/services/notifications/repositories/push_notifications_repository.dart';
import 'package:seren_ai_flutter/services/notifications/services/fcm_push_notification_service_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final log = Logger('UserInviteNotificationService');

final userInviteNotificationServiceProvider =
    Provider<UserInviteNotificationService>((ref) {
  return UserInviteNotificationService(ref);
});

/// Data class for user invite notifications
class UserInviteNotificationData extends NotificationData {
  final String orgId;
  final String orgName;
  final String role;
  final String authorUserName;

  UserInviteNotificationData({
    required this.orgId,
    required this.orgName,
    required this.role,
    required this.authorUserName,
    required super.type,
  });

  factory UserInviteNotificationData.create({
    required String orgId,
    required String orgName,
    required String role,
    required String authorUserName,
  }) {
    return UserInviteNotificationData(
      orgId: orgId,
      orgName: orgName,
      role: role,
      authorUserName: authorUserName,
      type: 'org_invite',
    );
  }

  @override
  Map<String, String> toJson() {
    return {
      'type': type,
      'orgId': orgId,
      'orgName': orgName,
      'role': role,
      'authorUserName': authorUserName,
    };
  }
}

/// Service for handling user invite notifications
///
/// This service is responsible for sending notifications to users
/// when they are invited to an organization.
/// Notice that it will only work for users who have already installed the app.
class UserInviteNotificationService {
  final Ref ref;

  UserInviteNotificationService(this.ref);

  Future<void> handleNewInvite({
    required String orgId,
    required String orgName,
    required String invitedUserEmail,
    required OrgRole role,
    required String authorUserName,
  }) async {
    final invitedUser = await ref.read(usersRepositoryProvider).getSingleOrNull(
          'SELECT * FROM users WHERE email = ?',
          {'email': invitedUserEmail},
        );

    // This exception is expected if the user has not installed the app yet.
    // But it's heppening for users that already exist in the database, due to permission issues.
    // TODO p1: move this invite notification to the "invite_user" rpc function.
    if (invitedUser == null) {
      log.info(
          'User not found for email: $invitedUserEmail. Cannot send invite notification.');
      return;
    }

    final recipients = [invitedUser.id];

    if (recipients.isEmpty) return;

    final context = ref.read(navigationServiceProvider).context;

    // Using the same messages from the commented dialog in main_scaffold.dart
    final title = AppLocalizations.of(context)!.pendingInvite;
    final body = AppLocalizations.of(context)!.pendingInviteBody(
      authorUserName,
      orgName,
      role.toHumanReadable(context),
    );

    final notificationData = UserInviteNotificationData.create(
      orgId: orgId,
      orgName: orgName,
      role: role.name,
      authorUserName: authorUserName,
    );

    final pushNotification = PushNotificationModel(
      userIds: recipients,
      referenceId: orgId,
      referenceType: notificationData.type,
      notificationTitle: title,
      notificationBody: body,
      sendAt: DateTime.now(),
      data: notificationData,
    );

    final pushNotificationId = await ref
        .read(pushNotificationsRepositoryProvider)
        .insertImmediately(pushNotification);

    await ref
        .read(fcmPushNotificationServiceProvider)
        .sendNotification(pushNotificationId);
  }
}
