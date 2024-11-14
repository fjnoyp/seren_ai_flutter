import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_thread_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/providers/cur_ai_chat_thread_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/providers/cur_user_ai_chat_thread_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/repositories/ai_chat_messages_repository.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/repositories/ai_chat_threads_repository.dart';


/*

0. take in thread id family - use the CurAiChatThreadDependencyProvider outside to load it

final curUserOpenShiftLogProvider = StreamProvider.autoDispose<ShiftLogModel?>((ref) {
  return CurShiftDependencyProvider.watchStream(
    ref: ref,
    builder: (userId, joinedShift) => ref.watch(shiftLogsRepositoryProvider).watchCurrentOpenLog(
      shiftId: joinedShift.shift.id,
      userId: userId,
    ),
  );
});




1. Auto load the first page
2. keep track of pages loaded 
3. have method to load more pages 

*/


// final curUserAiChatMessagesProvider = Provider.autoDispose<AsyncValue<List<AiChatMessageModel>>>((ref) {
//   return CurAiChatThreadDependencyProvider.watch(
//     ref: ref,
//     builder: (aiChatThread) => ref.watch(aiChatMessagesProvider(aiChatThread.id)),
//   );
// });


// TODO: wait on the curUserAiChatThreadProvider and then load this provider. 
// Make this provider return an empty list when loading. we can hold the async value until the first page loads ... 
final curUserAiChatMessagesProvider = Provider.autoDispose<AsyncValue<({
  List<AiChatMessageModel> state,
  AiChatMessagesNotifier notifier
})>>((ref) {

  // load the curthread id first 
  final aiChatThread = ref.watch(curUserAiChatThreadProvider);

  if(aiChatThread.hasError) {
    return AsyncValue.error(aiChatThread.error!, StackTrace.empty);
  }

  if(aiChatThread.isLoading) {
    return const AsyncValue.loading();
  }

  if(aiChatThread.hasValue && aiChatThread.value == null) {
    return AsyncValue.error(Exception('No thread found'), StackTrace.empty);
  }

  final thread = aiChatThread.value!;

  final aiChatMessages = ref.watch(_aiChatMessagesProvider(thread.id));
  final notifier = ref.watch(_aiChatMessagesProvider(thread.id).notifier);

  if(aiChatMessages.hasError) {
    return AsyncValue.error(aiChatMessages.error!, StackTrace.empty);
  }

  if(aiChatMessages.isLoading) {
    return const AsyncValue.loading();
  }

  // then load and return the provider 
  return AsyncValue.data((state: aiChatMessages.value!, notifier: notifier));
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