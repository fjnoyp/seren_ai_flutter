import 'package:flutter/foundation.dart';

class FirebaseCrashlytics {
  static final FirebaseCrashlytics instance = FirebaseCrashlytics();

  void recordFlutterFatalError(
      FlutterErrorDetails flutterErrorDetails){
    // No-op for web
  }

  void recordError(dynamic exception, StackTrace? stack, {bool fatal = false}) {
    // No-op for web
  }
}
