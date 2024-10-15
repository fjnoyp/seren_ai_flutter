import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/users_read_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final curAuthUserProvider = NotifierProvider<CurAuthUserNotifier, UserModel?>(CurAuthUserNotifier.new);

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
      if (error is _UserNotFoundError) {
        await _insertNotFoundUserAndTryAgain(user!);
      } else {
        state = null;
      }
    }
  }

  Future<void> _insertNotFoundUserAndTryAgain(User user) async {
    final usersCacherDatabase = ref.read(usersReadProvider);
    await usersCacherDatabase.upsertItem(
        UserModel(parentAuthUserId: user.id, email: user.email!));
    _updateUser(user);
  }

  Future<UserModel> _convertAuthUserIdToUserModel(String authUserId) async {
    final usersCacherDatabase = ref.read(usersReadProvider);
    final userModel = await usersCacherDatabase.getItem(
        eqFilters: [{'key': 'parent_auth_user_id', 'value': authUserId}]);
    if(userModel == null){
      throw _UserNotFoundError();
    }
    return userModel;
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    await ref.read(dbProvider).disconnectAndClear();
    state = null;
  }
}

final class _UserNotFoundError extends Error {}