import 'package:supabase_flutter/supabase_flutter.dart';

extension AddThrowErrorSupabase on PostgrestBuilder {
  Future end() {
    return catchError((error) {
      print('PostgrestBuilder error: $error');
      // You could add more detailed logging or custom error handling here
      throw error;
    });
  }
}