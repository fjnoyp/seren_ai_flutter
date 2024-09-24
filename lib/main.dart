import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/app.dart';
import 'package:seren_ai_flutter/services/data/db_setup/powersync.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialization of Async Components 
  final db = await PowerSyncDatabaseFactory.openDatabase();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const App(),
    ),
  );

    // == Wechat Assets Picker ==
    AssetPicker.registerObserve();
    // Enables logging with the photo_manager.
    PhotoManager.setLog(true);
}
