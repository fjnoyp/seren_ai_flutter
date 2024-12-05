import 'dart:io';

import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';

class UniversalPlatformNative extends UniversalPlatform {
  @override
  String get localeName => Platform.localeName;

  @override
  bool get isIOS => Platform.isIOS;
}

UniversalPlatform getUniversalPlatform() => UniversalPlatformNative();