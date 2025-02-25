import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart';
import 'package:seren_ai_flutter/app.dart';
import 'package:seren_ai_flutter/common/shared_preferences_service_provider.dart';
import 'package:seren_ai_flutter/firebase_options.dart';
import 'package:seren_ai_flutter/services/data/db_setup/powersync.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/notifications/helpers/fcm_push_notification_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// For showing notifications in the foreground
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  try {
    debugPrint('Starting app initialization...');
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('Flutter binding initialized');

    debugPrint('Initializing PowerSync Database...');
    PowerSyncDatabase db;
    try {
      db = await PowerSyncDatabaseFactory.openDatabase();
      debugPrint('PowerSync Database initialized');
    } catch (e, st) {
      debugPrint('Error initializing PowerSync on web: $e');
      debugPrint('Stack trace: $st');
      rethrow;
    }

    debugPrint('Initializing Firebase for Web...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase Web initialization successful');

    // Register FCM message listeners
    FCMPushNotificationHandler.instance
        .registerMessageListeners(scaffoldMessengerKey);

    // Log each async component initialization
    debugPrint('Initializing SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    debugPrint('SharedPreferences initialized');

    debugPrint('Setting up error handlers...');
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Flutter Error: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');
    };
    debugPrint('Error handlers set up');

    debugPrint('Running app with ProviderScope...');
    runApp(
      ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const App(),
      ),
    );
    debugPrint('App running');
  } catch (e, stack) {
    debugPrint('FATAL ERROR during initialization: $e');
    debugPrint('Stack trace: $stack');
    rethrow;
  }
}
