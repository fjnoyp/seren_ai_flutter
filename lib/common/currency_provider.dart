import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/common/shared_preferences_service_provider.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';

final currencyFormatSNP =
    StateNotifierProvider<CurrencyFormatSN, NumberFormat>((ref) {
  return CurrencyFormatSN(ref);
});

class CurrencyFormatSN extends StateNotifier<NumberFormat> {
  final Ref ref;

  CurrencyFormatSN(this.ref)
      : super(NumberFormat.simpleCurrency(
            locale: UniversalPlatform.instance().normalizedLanguage)) {
    ref.listen(curUserProvider, (_, __) => _loadCurrency());
  }

  void _loadCurrency() {
    final prefs = ref.read(sharedPreferencesServiceProvider);
    final savedCurrency = prefs.getString('currency_locale');
    if (savedCurrency != null) {
      // if there's a saved currency, use it
      state = NumberFormat.simpleCurrency(locale: savedCurrency);
    }
    // otherwise, use the current language to get a default currency
    // (it's already set in the constructor)
  }

  Future<void> setCurrency(String currencyLocale) async {
    try {
      state = NumberFormat.simpleCurrency(locale: currencyLocale);
      final prefs = ref.read(sharedPreferencesServiceProvider);
      await prefs.setString('currency_locale', currencyLocale);
    } catch (e) {
      // Log the error but keep the state updated anyway
      log('Error saving currency preference: $e');
    }
  }
}
