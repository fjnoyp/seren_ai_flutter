import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';

/// Helper to create providers that depend on authenticated user
class CurAuthDependencyProvider {
  static AsyncValue<T> watch<T>({
    required Ref ref,
    required T Function(String userId) builder,
  }) {
    // Handle auth state
    final authState = ref.watch(curAuthStateProvider);
    
    if (authState is LoadingAuthState) {
      return const AsyncValue.loading();
    }
    if (authState is LoggedOutAuthState) {
      return const AsyncValue.error('Not authenticated', StackTrace.empty);
    }
    if (authState is! LoggedInAuthState) {
      return const AsyncValue.error('Invalid auth state', StackTrace.empty);
    }
    
    // Auth satisfied, build the result
    return AsyncValue.data(builder(authState.user.id));
  }
  
  static Stream<T> watchStream<T>({
    required Ref ref,
    required Stream<T> Function(String userId) builder,
  }) {
    // Handle auth state
    final authState = ref.watch(curAuthStateProvider);
    if (authState is! LoggedInAuthState) {
      return Stream.error('Not authenticated');
    }
    
    // Auth satisfied, build the stream
    return builder(authState.user.id);
  }
}
