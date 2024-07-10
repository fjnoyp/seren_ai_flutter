import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/users_cacher_database_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final curAuthUserProvider =
    StateNotifierProvider<CurAuthUserNotifier, UserModel?>((ref) {
  return CurAuthUserNotifier(ref);
});

class CurAuthUserNotifier extends StateNotifier<UserModel?> {
  final Ref ref;

  CurAuthUserNotifier(this.ref) : super(null) {
    // Initially set the user
    final authUserId = Supabase.instance.client.auth.currentUser?.id;
    convertAuthUserIdToUserModel(authUserId).then((user) {
      state = user;
    });

    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      convertAuthUserIdToUserModel(data.session?.user.id).then((user) {
        state = user;
      });
    });
  }

  Future<UserModel?> convertAuthUserIdToUserModel(String? authUserId) async {
    if (authUserId == null) {
      return null;
    }
    final usersCacherDatabase = ref.read(usersCacherDatabaseProvider);
    return await usersCacherDatabase.getItem(
        eqFilters: [{'key' : 'parent_auth_user_id', 'value': authUserId}]);
  }

  signOut() {
    Supabase.instance.client.auth.signOut();
    state = null;
  }
}
