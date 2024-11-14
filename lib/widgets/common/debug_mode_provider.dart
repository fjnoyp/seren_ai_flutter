import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final isDebugModeSNP = StateNotifierProvider<DebugModeSN, bool>((ref) {
  return DebugModeSN();
});

class DebugModeSN extends StateNotifier<bool> {
  DebugModeSN() : super(false) {
    _loadDebugMode();
  }

  Future<void> _loadDebugMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDebugMode = prefs.getBool('isDebugMode') ?? false;
    state = isDebugMode;
  }

  Future<void> setIsDebugMode(bool isDebugMode) async {
    state = isDebugMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDebugMode', isDebugMode);
  }
}
