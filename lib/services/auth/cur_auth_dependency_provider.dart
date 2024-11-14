import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';

/// Helper to create providers that depend on authenticated user
class CurAuthDependencyProvider {
  static AsyncValue<T> watch<T>({
    required Ref ref,
    required AsyncValue<T> Function(String userId) builder,
  }) {
    final authState = ref.watch(curUserProvider);

    return authState.when(
      data: (user) => builder(user?.id ?? ''),
      error: (error, _) => AsyncValue.error(error, StackTrace.empty),
      loading: () => const AsyncValue.loading(),
    );
  }

  static Stream<T> watchStream<T>({
    required Ref ref,
    required Stream<T> Function(String userId) builder,
  }) {
    final authState = ref.watch(curUserProvider);

    return authState.when(
      data: (user) => builder(user?.id ?? ''),
      error: (error, _) => Stream.error(error),
      loading: () => const Stream.empty(),
    );
  }

}
