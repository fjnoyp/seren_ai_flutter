import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org_local_key.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/is_cur_user_org_admin_listener_provider.dart';
import 'package:seren_ai_flutter/services/shared_preferences_provider.dart';

// As we're using shared preferences, the call is synchronous
// and we need to refresh the provider when the value changes.
// it's done at lib/services/data/orgs/providers/cur_user_org_service_provider.dart
final curOrgIdProvider = Provider<String?>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return prefs.getString(orgIdKey);
});


/// Helper to create providers that depend on authenticated user
class IsCurUserOrgAdminDependencyProvider {
  static AsyncValue<T> get<T>({
    required Ref ref,
    required AsyncValue<T> Function(bool isAdmin) builder,
  }) {
    final isOrgAdmin = ref.watch(isCurUserOrgAdminProvider);

    return isOrgAdmin.when(
      data: (isAdmin) => builder(isAdmin),
      error: (error, _) => AsyncValue.error(error, StackTrace.empty),
      loading: () => const AsyncValue.loading(),
    );
  }

  static Stream<T> watchStream<T>({
    required Ref ref,
    required Stream<T> Function(bool isAdmin) builder,
  }) {
    final isOrgAdmin = ref.watch(isCurUserOrgAdminProvider);

    return isOrgAdmin.when(
      data: (isAdmin) => builder(isAdmin),
      error: (error, _) => Stream.error(error),
      loading: () => const Stream.empty(),
    );
  }
}
