import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class AppConfig {
  static const bool isProdMode =
      false; // Set to true for production environment

  // Simple platform check that works for web and mobile
  static bool get isAndroid {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  static String get localSupabaseUrl =>
      isAndroid ? 'http://10.0.2.2:54321' : 'http://127.0.0.1:54321';

  static String get localPowersyncUrl =>
      isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';

  static String get localLanggraphUrl =>
      isAndroid ? 'http://10.0.2.2:8123' : 'http://localhost:8123';

  static String get supabaseUrl =>
      isProdMode ? 'YOUR_PRODUCTION_SUPABASE_URL' : localSupabaseUrl;
  static String get supabaseAnonKey => isProdMode
      ? 'YOUR_PRODUCTION_SUPABASE_ANON_KEY'
      : 'YOUR_LOCAL_SUPABASE_ANON_KEY';
  static String get powersyncUrl =>
      isProdMode ? 'YOUR_PRODUCTION_POWERSYNC_URL' : localPowersyncUrl;
  static const String supabaseStorageBucket =
      ''; // Optional. Only required when syncing attachments and using Supabase Storage.

  static const String langgraphApiKey = 'YOUR_LANGGRAPH_API_KEY';
  static String get langgraphBaseUrl =>
      isProdMode ? 'YOUR_PRODUCTION_LANGGRAPH_URL' : localLanggraphUrl;
}
