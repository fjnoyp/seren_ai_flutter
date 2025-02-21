//import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/providers/cur_ai_chat_thread_dependency_provider.dart';
//import 'package:seren_ai_flutter/services/data/ai_chats/providers/cur_user_ai_chat_thread_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/repositories/ai_chat_messages_repository.dart';

final curUserAiChatMessagesStreamProvider =
    StreamProvider.autoDispose<List<AiChatMessageModel>>((ref) {
  return CurAiChatThreadDependencyProvider.watchStream(
    ref: ref,
    builder: (aiChatThread) {
      return ref
          .watch(aiChatMessagesRepositoryProvider)
          .watchThreadMessages(threadId: aiChatThread.id);
    },
  );
});


// Disable for now .. pagination not working 
// Should be simplified to be a single stream provider ... 

// final curUserPaginatedAiChatMessagesProvider = Provider<
//     AsyncValue<
//         ({
//           List<AiChatMessageModel> state,
//           _AiChatMessagesNotifier notifier
//         })>>((ref) {
//   final aiChatThread = ref.watch(curUserAiChatThreadProvider);

//   return aiChatThread.when(
//     error: (error, stack) => AsyncValue.error(error, stack),
//     loading: () => const AsyncValue.loading(),
//     data: (thread) {
//       if (thread == null) {
//         return AsyncValue.error(Exception('No thread found'), StackTrace.empty);
//       }

//       final aiChatMessages = ref.watch(_aiChatMessagesSNP(thread.id));
//       final notifier = ref.watch(_aiChatMessagesSNP(thread.id).notifier);

//       return aiChatMessages.when(
//         error: (error, stack) => AsyncValue.error(error, stack),
//         loading: () => const AsyncValue.loading(),
//         data: (messages) => AsyncValue.data((
//           state: messages,
//           notifier: notifier,
//         )),
//       );
//     },
//   );
// });

// final _aiChatMessagesSNP = StateNotifierProvider.family.autoDispose<
//     _AiChatMessagesNotifier,
//     AsyncValue<List<AiChatMessageModel>>,
//     String>((ref, threadId) {
//   final repository = ref.watch(aiChatMessagesRepositoryProvider);
//   return _AiChatMessagesNotifier(repository, threadId);
// });

// class _AiChatMessagesNotifier
//     extends StateNotifier<AsyncValue<List<AiChatMessageModel>>> {
//   final String threadId;

//   _AiChatMessagesNotifier(this._repository, this.threadId)
//       : super(const AsyncValue.loading()) {
//     loadMessages();
//     _repository
//         .watchThreadMessages(threadId: threadId)
//         .skip(1)
//         .listen((newMessages) {
//       if (state case AsyncData(value: var currentMessages)) {
//         if (newMessages.first.id == currentMessages.first.id) {
//           return;
//         }
//         state = AsyncValue.data([newMessages.first, ...currentMessages]);
//         hasNewMessages = true;
//         log('refreshed with new messages');
//       }
//     });
//   }

//   final AiChatMessagesRepository _repository;
//   final int pageSize = AiChatMessagesRepository.defaultPageSize;
//   int _currentPage = 1;
//   bool _hasMore = true;
//   bool hasNewMessages = false;

//   Future<void> loadMessages() async {
//     try {
//       final messages = await _repository.getThreadMessages(
//         threadId: threadId,
//         limit: pageSize,
//         offset: (_currentPage - 1) * pageSize,
//       );

//       if (messages.length < pageSize) {
//         _hasMore = false;
//       }

//       if (_currentPage == 1) {
//         state = AsyncValue.data(messages);
//       } else {
//         final currentMessages = state.value ?? [];
//         state = AsyncValue.data([...currentMessages, ...messages]);
//       }
//     } catch (error, stack) {
//       state = AsyncValue.error(error, stack);
//     }
//   }

//   Future<void> loadMore() async {
//     if (!_hasMore || state.isLoading) return;
//     _currentPage++;
//     await loadMessages();
//     log('loaded more messages');
//   }

//   bool get hasMore => _hasMore;
// }
