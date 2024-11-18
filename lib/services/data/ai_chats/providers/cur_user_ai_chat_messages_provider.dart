import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/providers/cur_ai_chat_thread_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/providers/cur_user_ai_chat_thread_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/repositories/ai_chat_messages_repository.dart';

final curUserAiChatMessagesProvider =
    StreamProvider.autoDispose<List<AiChatMessageModel>>((ref) {
  return CurAiChatThreadDependencyProvider.watchStream(
    ref: ref,
    builder: (aiChatThread) {
      return ref
          .watch(aiChatMessagesRepositoryProvider)
          .watchThreadMessages(threadId: aiChatThread.id ?? '');
    },    
  );
});

final curUserPaginatedAiChatMessagesProvider = Provider.autoDispose<AsyncValue<({
  List<AiChatMessageModel> state,
  AiChatMessagesNotifier notifier
})>>((ref) {
  final aiChatThread = ref.watch(curUserAiChatThreadProvider);
  
  return aiChatThread.when(
    error: (error, stack) => AsyncValue.error(error, stack),
    loading: () => const AsyncValue.loading(),
    data: (thread) {
      if (thread == null) {
        return AsyncValue.error(Exception('No thread found'), StackTrace.empty);
      }

      final aiChatMessages = ref.watch(_aiChatMessagesProvider(thread.id));
      final notifier = ref.watch(_aiChatMessagesProvider(thread.id).notifier);
      
      return aiChatMessages.when(
        error: (error, stack) => AsyncValue.error(error, stack),
        loading: () => const AsyncValue.loading(),
        data: (messages) => AsyncValue.data((
          state: messages,
          notifier: notifier,
        )),
      );
    },
  );
});

final _aiChatMessagesProvider = StateNotifierProvider.family
    .autoDispose<AiChatMessagesNotifier, AsyncValue<List<AiChatMessageModel>>, String>((ref, threadId) {
  final repository = ref.watch(aiChatMessagesRepositoryProvider);
  return AiChatMessagesNotifier(repository, threadId);
});

class AiChatMessagesNotifier extends StateNotifier<AsyncValue<List<AiChatMessageModel>>> {
  
  final String threadId;

  AiChatMessagesNotifier(this._repository, this.threadId) : super(const AsyncValue.loading()) {
    loadMessages();
  }

  final AiChatMessagesRepository _repository;
  final int pageSize = AiChatMessagesRepository.defaultPageSize;
  int _currentPage = 1;
  bool _hasMore = true;

  Future<void> loadMessages() async {    

    try {
      final messages = await _repository.getThreadMessages(
        threadId: threadId,
        limit: pageSize,
        offset: (_currentPage - 1) * pageSize,
      );

      if (messages.length < pageSize) {
        _hasMore = false;
      }

      if (_currentPage == 1) {
        state = AsyncValue.data(messages);
      } else {
        final currentMessages = state.value ?? [];
        state = AsyncValue.data([...currentMessages, ...messages]);
      }
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;
    _currentPage++;
    await loadMessages();
  }

  bool get hasMore => _hasMore;
}