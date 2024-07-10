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
      child: App(),
    ),
  );
}
