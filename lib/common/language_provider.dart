import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

final languageSNP = StateNotifierProvider<LanguageSN, String>((ref) {
  return LanguageSN();
});

class LanguageSN extends StateNotifier<String> {
  LanguageSN() : super(Platform.localeName) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('language') ?? Platform.localeName;
    state = language;
  }

  Future<void> setLanguage(String language) async {
    state = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }
}
