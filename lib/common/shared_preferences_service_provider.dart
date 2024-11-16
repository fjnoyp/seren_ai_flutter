import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not overridden');
});

final sharedPreferencesServiceProvider = Provider<SharedPreferencesService>(
  (ref) => SharedPreferencesService(ref),
);

class SharedPreferencesService {
  final Ref ref;

  late SharedPreferences _prefs;
  String _curUserId = '';

  SharedPreferencesService(this.ref) {
    _prefs = ref.read(sharedPreferencesProvider);
    _curUserId = ref.watch(curUserProvider).value?.id ?? '';
  }

  Future<void> setString(String key, String value) async =>
      await _prefs.setString('${_curUserId}_$key', value);

  String? getString(String key) => _prefs.getString('${_curUserId}_$key');

  Future<void> setBool(String key, bool value) async =>
      await _prefs.setBool('${_curUserId}_$key', value);

  bool? getBool(String key) => _prefs.getBool('${_curUserId}_$key');

  Future<void> setInt(String key, int value) async =>
      await _prefs.setInt('${_curUserId}_$key', value);

  int? getInt(String key) => _prefs.getInt('${_curUserId}_$key');

  Future<void> remove(String key) async =>
      await _prefs.remove('${_curUserId}_$key');
}
