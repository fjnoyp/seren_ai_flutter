import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    //url: 'https://***REMOVED***.supabase.co',
    url: 'http://127.0.0.1:54321', // Your local Supabase URL
    anonKey:
        '***REMOVED***.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5xZ21ja3FpenV1c3Rjd3NvbHRhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTE0NzAwNzksImV4cCI6MjAyNzA0NjA3OX0.***REMOVED***',
  );
  runApp(
    const ProviderScope(
      child: EagerInitialization(
        child: App(),
      ),
    ),
  );
}

/// Eagerly initialize providers by watching them.
class EagerInitialization extends ConsumerWidget {
  const EagerInitialization({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Eagerly initialize providers by watching them.
    // By using "watch", the provider will stay alive and not be disposed.
    //ref.watch(curUserTasksListListenerDatabaseProvider);
    return child;
  }
}