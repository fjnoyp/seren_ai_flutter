import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/shared_preferences_service_provider.dart';
import 'dart:io';

import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';

final languageSNP = StateNotifierProvider<LanguageSN, String>((ref) {
  return LanguageSN(ref);
});

class LanguageSN extends StateNotifier<String> {
  final Ref ref;

  LanguageSN(this.ref) : super(Platform.localeName) {
    ref.listen(curUserProvider, (_, __) => _loadLanguage());
  }

  void _loadLanguage() {
    final prefs = ref.read(sharedPreferencesServiceProvider);
    final language = prefs.getString('language') ?? Platform.localeName;
    state = language;
  }

  Future<void> setLanguage(String language) async {
    state = language;
    final prefs = ref.read(sharedPreferencesServiceProvider);
    await prefs.setString('language', language);
  }
}
