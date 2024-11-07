import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_task_state_provider.dart';

/// Helper Provider that provides the current task for other providers
class CurTaskDependencyProvider {
  static AsyncValue<T> watch<T>({
    required Ref ref,
    required T Function(JoinedTaskModel task) builder,
  }) {
    final taskState = ref.watch(curTaskStateProvider);

    return taskState.when(
      loading: () => const AsyncValue.loading(),
      error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
      data: (joinedTask) {
        if (joinedTask == null) {
          return const AsyncValue.error('No active task', StackTrace.empty);
        }
        return AsyncValue.data(builder(joinedTask));
      },
    );
  }

  static Stream<T> watchStream<T>({
    required Ref ref,
    required Stream<T> Function(JoinedTaskModel task) builder,
  }) {
    final taskState = ref.watch(curTaskStateProvider);

    return taskState.when(
      loading: () => Stream.error('Loading task state'),
      error: (error, stackTrace) => Stream.error('Error fetching task state: $error'),
      data: (joinedTask) {
        if (joinedTask == null) {
          return Stream.error('No active task');
        }
        return builder(joinedTask);
      },
    );
  }
}

