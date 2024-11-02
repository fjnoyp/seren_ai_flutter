import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/shift_state_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/joined_shift_model.dart';

/// Helper to create providers that depend on authenticated user and/or current shift
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
        
    // Then handle shift state
    final shiftState = ref.watch(curUserShiftStateProvider);
    
    if (shiftState is CurUserShiftLoading) {
      return const AsyncValue.loading();
    }
    if (shiftState is CurUserShiftError) {
      return AsyncValue.error(shiftState.errorMessage, StackTrace.empty);
    }
    if (shiftState is! CurUserShiftLoaded) {
      return const AsyncValue.error('Invalid shift state', StackTrace.empty);
    }
    if(shiftState.joinedShift == null) {
      return const AsyncValue.error('No active shift', StackTrace.empty);
    }
    
    // All dependencies satisfied, build the result
    return AsyncValue.data(builder(
      authState.user.id,
      shiftState.joinedShift!,
    ));
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
    final shiftState = ref.watch(curUserShiftStateProvider);
    if (shiftState is! CurUserShiftLoaded) {
      return Stream.error('No active shift');
    }
    if(shiftState.joinedShift == null) {
      return Stream.error('No active shift');
    }
    
    // All dependencies satisfied, build the stream
    return builder(
      authState.user.id,
      shiftState.joinedShift!,
    );
  }
}