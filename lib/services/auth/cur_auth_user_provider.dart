import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/users_read_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final curAuthUserProvider = NotifierProvider<CurAuthUserNotifier, UserModel?>(CurAuthUserNotifier.new);

class CurAuthUserNotifier extends Notifier<UserModel?> {
    
  @override
  UserModel? build() {
    final authUserId = Supabase.instance.client.auth.currentUser?.id;
    _updateUser(authUserId);

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _updateUser(data.session?.user.id);
    });

    return null; 
  }

  Future<void> _updateUser(String? authUserId) async {    
    if(authUserId == null) {
      state = null;
      return; 
    } 

    try {
      final user = await _convertAuthUserIdToUserModel(authUserId);
      state = user;
    } catch (error) {
      state = null;
    }
  }

  Future<UserModel> _convertAuthUserIdToUserModel(String authUserId) async {
    final usersCacherDatabase = ref.read(usersReadProvider);
    final userModel = await usersCacherDatabase.getItem(
        eqFilters: [{'key': 'parent_auth_user_id', 'value': authUserId}]);
    if(userModel == null){
      throw Exception('User not found');
    }
    return userModel;
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    await ref.read(dbProvider).disconnectAndClear();
    state = null;
  }
}