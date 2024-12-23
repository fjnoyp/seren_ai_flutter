//import 'dart:io';

import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart'
    if (dart.library.html) 'package:seren_ai_flutter/common/firebase_crashlytics/firebase_crashlytics_web_stub.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/app.dart';
import 'package:seren_ai_flutter/common/shared_preferences_service_provider.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/data/db_setup/powersync.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/notifications/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialization of Async Components
  final db = await PowerSyncDatabaseFactory.openDatabase();
  final prefs = await SharedPreferences.getInstance();

  if (!kIsWeb && !UniversalPlatform.instance().isIOS) {
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

  final notificationService = NotificationService();
  if (!kIsWeb) {
    // Initialize Notification Service
    await notificationService.initialize();
  }

  runApp(
    ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const App(),
    ),
  );
}
