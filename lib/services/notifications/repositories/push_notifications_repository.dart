import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/notifications/models/push_notification_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final pushNotificationsRepositoryProvider =
    Provider<PushNotificationsRepository>((ref) {
  return PushNotificationsRepository(ref.watch(dbProvider), ref);
});

class PushNotificationsRepository
    extends BaseRepository<PushNotificationModel> {
  final Ref ref;

  const PushNotificationsRepository(super.db, this.ref,
      {super.primaryTable = 'push_notifications'});

  @override
  PushNotificationModel fromJson(Map<String, dynamic> json) {
    return PushNotificationModel.fromJson(json);
  }

  Future<String> insertImmediately(
      PushNotificationModel pushNotification) async {
    final response = await Supabase.instance.client
        .from(primaryTable)
        .insert(pushNotification.toJson())
        .select()
        .single();

    return response['id'];
  }
}
