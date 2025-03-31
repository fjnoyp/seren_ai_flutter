import 'package:flutter/foundation.dart';

import 'universal_platform_stub.dart'
    if (dart.library.io) 'universal_platform_native.dart'
    if (dart.library.html) 'universal_platform_web.dart';

abstract class UniversalPlatform {
  String get localeName;

  String get normalizedLanguage => localeName
      .replaceAll('-', '_')
      .split('_')
      .map((part) => part.toUpperCase())
      .join('_');

  bool get isIOS;

  static UniversalPlatform instance() => getUniversalPlatform();
}

final isWebVersion = kIsWeb &&
    !(defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);
