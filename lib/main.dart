import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/app.dart';
import 'package:seren_ai_flutter/services/data/db_setup/powersync.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await PowerSyncDatabaseFactory.openDatabase();

  runApp(
    ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(db),
      ],
      child: const App(),
    ),
  );
}
