import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logging/logging.dart';

final log = Logger('ThrowErrorSupabase');

extension AddThrowErrorSupabase on PostgrestBuilder {
  Future end() {
    return catchError((error) {
      log.severe('PostgrestBuilder error: $error');
      // You could add more detailed logging or custom error handling here
      throw error;
    });
  }
}