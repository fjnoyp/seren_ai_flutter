import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final curAuthUserProvider =
    NotifierProvider<CurAuthUserNotifier, AppAuthState>(CurAuthUserNotifier.new);

class CurAuthUserNotifier extends Notifier<AppAuthState> {
  @override
  AppAuthState build() {
    final authUser = Supabase.instance.client.auth.currentUser;
    _updateUser(authUser);

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _updateUser(data.session?.user);
    });

    return InitialAuthState();
  }

  Future<void> _updateUser(User? user) async {
    if (user?.id == null) {
      state = LoggedOutAuthState();
      return;
    }

    state = LoadingAuthState();

    try {
      final userModel = await _convertAuthUserIdToUserModel(user!.id);
      state = LoggedInAuthState(userModel);
    } catch (error) {
      state = ErrorAuthState(error: error.toString());
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
    state = LoggedOutAuthState();
  }
}
