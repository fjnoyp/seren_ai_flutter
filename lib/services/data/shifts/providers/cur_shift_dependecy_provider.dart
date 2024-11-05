import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/cur_shift_state_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/joined_shift_model.dart';

/// Helper Provider that provides the current auth id and shift for other providers 
class CurShiftDependencyProvider {
  static AsyncValue<T> watch<T>({
    required Ref ref,
    required T Function(String userId, JoinedShiftModel shift) builder,
  }) {
    // Handle auth state first
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
    final shiftState = ref.watch(curShiftStateProvider);

    return shiftState.when(
      loading: () => const AsyncValue.loading(),
      error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
      data: (joinedShift) {
        if (joinedShift == null) {
          return const AsyncValue.error('No active shift', StackTrace.empty);
        }
        // All dependencies satisfied, build the result
        return AsyncValue.data(builder(
          authState.user.id,
          joinedShift,
        ));
      },
    );
  }

  static Stream<T> watchStream<T>({
    required Ref ref,
    required Stream<T> Function(String userId, JoinedShiftModel shift) builder,
  }) {
    // Handle auth state first
    final authState = ref.watch(curAuthStateProvider);
    if (authState is! LoggedInAuthState) {
      return Stream.error('Not authenticated');
    }

    // Then handle shift state
    final shiftState = ref.watch(curShiftStateProvider);
    return shiftState.when(
      loading: () => Stream.error('Loading shift state'),
      error: (error, stackTrace) =>
          Stream.error('Error fetching shift state: $error'),
      data: (joinedShift) {
        if (joinedShift == null) {
          return Stream.error('No active shift');
        }

        // All dependencies satisfied, build the stream
        return builder(
          authState.user.id,
          joinedShift,
        );
      },
    );
  }
}
