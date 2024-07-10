import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final curAuthUserProvider = StateNotifierProvider<CurAuthUserNotifier, User?>((ref) {
  return CurAuthUserNotifier();
});

class CurAuthUserNotifier extends StateNotifier<User?> {
  CurAuthUserNotifier() : super(null) {
    // Initially set the user
    state = Supabase.instance.client.auth.currentUser;

    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      state = data.session?.user;
    });
  }

  signOut() {
    Supabase.instance.client.auth.signOut();
    state = null; 
  }
}
