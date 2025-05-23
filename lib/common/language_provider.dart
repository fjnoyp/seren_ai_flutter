import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/shared_preferences_service_provider.dart';
///import 'dart:io';

import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';

import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';

final languageSNP = StateNotifierProvider<LanguageSN, String>((ref) {
  return LanguageSN(ref);
});

class LanguageSN extends StateNotifier<String> {
  final Ref ref;  

  LanguageSN(this.ref) : super(UniversalPlatform.instance().localeName) {
    ref.listen(curUserProvider, (_, __) => _loadLanguage());
  }

  void _loadLanguage() {
    final prefs = ref.read(sharedPreferencesServiceProvider);
    final language = prefs.getString('language') ?? UniversalPlatform.instance().localeName;

    // Parse between web and mobile formats
    final normalizedLanguage = language.replaceAll('-', '_')
        .split('_')
        .map((part) => part.toUpperCase())
        .join('_');
    state = normalizedLanguage;
  }

  Future<void> setLanguage(String language) async {
    state = language;
    final prefs = ref.read(sharedPreferencesServiceProvider);
    await prefs.setString('language', language);
  }
}
