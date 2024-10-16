import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/users_read_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final curAuthUserProvider =
    NotifierProvider<CurAuthUserNotifier, UserModel?>(CurAuthUserNotifier.new);

class CurAuthUserNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() {
    final authUser = Supabase.instance.client.auth.currentUser;
    _updateUser(authUser);

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _updateUser(data.session?.user);
    });

    return null;
  }

  Future<void> _updateUser(User? user) async {
    if (user?.id == null) {
      state = null;
      return;
    }

    try {
      final userModel = await _convertAuthUserIdToUserModel(user!.id);
      state = userModel;
    } catch (error) {
      state = null;
    }
  }

  Future<UserModel> _convertAuthUserIdToUserModel(String authUserId) async {
    final supabaseFetchedUsers = await Supabase.instance.client
        .from('users')
        .select()
        .eq('parent_auth_user_id', authUserId);
    if (supabaseFetchedUsers.isEmpty) {
      throw _UserNotFoundError();
    }
    return UserModel.fromJson(supabaseFetchedUsers.first);
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    await ref.read(dbProvider).disconnectAndClear();
    state = null;
  }
}

final class _UserNotFoundError extends Error {}
