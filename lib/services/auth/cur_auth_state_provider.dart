import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/notifications/fcm_push_notification_service_provider.dart';
import 'package:seren_ai_flutter/services/notifications/services/fcm_device_token_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UnauthorizedException implements Exception {
  final String message = 'User must be authorized to perform this action';

  UnauthorizedException();
}

final curUserProvider =
    NotifierProvider<CurUserNotifier, AsyncValue<UserModel?>>(
        CurUserNotifier.new);

class CurUserNotifier extends Notifier<AsyncValue<UserModel?>> {
  @override
  AsyncValue<UserModel?> build() {
    final authUser = Supabase.instance.client.auth.currentUser;
    updateUser(authUser);

    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      await updateUser(data.session?.user);

      // Only handle FCM token refresh/save/updates when user is signed in - since tokens are associated with a user
      if (data.session != null) {
        ref.read(fcmDeviceTokenServiceProvider).initialize();
      } else {
        ref.read(fcmDeviceTokenServiceProvider).deInitialize();
      }
    });

    return const AsyncValue.loading();
  }

  Future<void> updateUser(User? user) async {
    if (user?.id == null) {
      state = const AsyncValue.data(null);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final userModel = await _convertAuthUserIdToUserModel(user!.id);
      state = AsyncValue.data(userModel);
    } catch (error) {
      state = AsyncValue.error(error.toString(), StackTrace.empty);
    }
  }

  Future<UserModel> _convertAuthUserIdToUserModel(String authUserId) async {
    final supabaseFetchedUsers = await Supabase.instance.client
        .from('users')
        .select()
        .eq('parent_auth_user_id', authUserId);
    if (supabaseFetchedUsers.isEmpty) {
      throw 'User not found';
    }
    return UserModel.fromJson(supabaseFetchedUsers.first);
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    await ref.read(dbProvider).disconnectAndClear();
    state = const AsyncValue.data(null);
  }
}
