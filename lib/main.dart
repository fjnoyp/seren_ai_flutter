import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/app.dart';
import 'package:seren_ai_flutter/common/shared_preferences_service_provider.dart';
import 'package:seren_ai_flutter/services/data/db_setup/powersync.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialization of Async Components
  final db = await PowerSyncDatabaseFactory.openDatabase();
  final prefs = await SharedPreferences.getInstance();
  
  if (!kIsWeb && !Platform.isIOS) {
    // Initialize Firebase for Crashlytics
    await Firebase.initializeApp();
    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  runApp(
    ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const App(),
    ),
  );
}
