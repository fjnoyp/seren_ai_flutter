import 'dart:html' as html;
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';

class UniversalPlatformWeb extends UniversalPlatform {
  @override
  String get localeName {
    // Get browser's language preference
    final browserLocale = html.window.navigator.language;
    return browserLocale;
  }

  @override
  bool get isIOS {
    return false; 
  }
}

UniversalPlatform getUniversalPlatform() => UniversalPlatformWeb();