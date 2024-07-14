import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/users_cacher_database_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final curAuthUserProvider = StateNotifierProvider<CurAuthUserNotifier, UserModel?>((ref) {
  return CurAuthUserNotifier(ref);
});

class CurAuthUserNotifier extends StateNotifier<UserModel?> {
  final Ref ref;

  CurAuthUserNotifier(this.ref) : super(null) {
    _init();
  }

  Future<void> _init() async {
    final authUserId = Supabase.instance.client.auth.currentUser?.id;
    _updateUser(authUserId);

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _updateUser(data.session?.user.id);
    });
  }

  Future<void> _updateUser(String? authUserId) async {    
    if(authUserId == null) {
      state = null;
      return; 
    } 

    try {
      final user = await convertAuthUserIdToUserModel(authUserId);
      state = user;
    } catch (error) {
      state = null;
    }
  }

  Future<UserModel> convertAuthUserIdToUserModel(String authUserId) async {
    final usersCacherDatabase = ref.read(usersCacherDatabaseProvider);
    final userModel = await usersCacherDatabase.getItem(
        eqFilters: [{'key': 'parent_auth_user_id', 'value': authUserId}]);
    if(userModel == null){
      throw Exception('User not found');
    }
    return userModel;
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    state = null;
  }
}