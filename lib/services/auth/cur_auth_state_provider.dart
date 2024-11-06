import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final curUserProvider =
    NotifierProvider<CurUserNotifier, AsyncValue<UserModel?>>(
        CurUserNotifier.new);

class CurUserNotifier extends Notifier<AsyncValue<UserModel?>> {
  @override
  AsyncValue<UserModel?> build() {
    final authUser = Supabase.instance.client.auth.currentUser;
    _updateUser(authUser);

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _updateUser(data.session?.user);
    });

    return const AsyncValue.loading();
  }

  Future<void> _updateUser(User? user) async {
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
