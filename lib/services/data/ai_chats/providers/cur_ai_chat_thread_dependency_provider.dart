import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_thread_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/providers/cur_user_ai_chat_thread_provider.dart';

/// Helper to create providers that depend on authenticated user
class CurAiChatThreadDependencyProvider {

  static AsyncValue<T> get<T>({
    required Ref ref,
    required AsyncValue<T> Function(AiChatThreadModel aiChatThread) builder,
  }) {
    final aiChatThreadState = ref.watch(curUserAiChatThreadProvider);

    return aiChatThreadState.when(
      data: (aiChatThread) {
        if (aiChatThread == null) {
          throw Exception('AiChatThread is null');
        }
        return builder(aiChatThread);
      },
      error: (error, _) => AsyncValue.error(error, StackTrace.empty),
      loading: () => const AsyncValue.loading(),
    );
  }

  static Stream<T> watchStream<T>({
    required Ref ref,
    required Stream<T> Function(AiChatThreadModel aiChatThread) builder,
  }) {
    final aiChatThreadState = ref.watch(curUserAiChatThreadProvider);

    return aiChatThreadState.when(
      data: (aiChatThread) {
        if (aiChatThread == null) {
          throw Exception('AiChatThread is null');
        }
        return builder(aiChatThread);
      },
      error: (error, _) => Stream.error(error),
      loading: () => const Stream.empty(),
    );
  }
}
