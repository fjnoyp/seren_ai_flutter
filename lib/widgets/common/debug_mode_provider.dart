import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/shared_preferences_service_provider.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';

final isDebugModeSNP = StateNotifierProvider<DebugModeSN, bool>((ref) {
  return DebugModeSN(ref);
});

class DebugModeSN extends StateNotifier<bool> {
  final Ref ref;

  DebugModeSN(this.ref) : super(false) {
    ref.listen(curUserProvider, (_, __) => _loadIsDebugMode());
  }

  void _loadIsDebugMode() {
    final prefs = ref.read(sharedPreferencesServiceProvider);
    final isDebugMode = prefs.getBool('isDebugMode') ?? false;
    state = isDebugMode;
  }

  Future<void> setIsDebugMode(bool isDebugMode) async {
    state = isDebugMode;
    final prefs = ref.read(sharedPreferencesServiceProvider);
    await prefs.setBool('isDebugMode', isDebugMode);
  }
}
