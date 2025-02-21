import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';
import 'package:seren_ai_flutter/services/ai/ai_chats/models/ai_chat_thread_model.dart';
import 'package:seren_ai_flutter/services/ai/ai_chats/repositories/ai_chat_threads_repository.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';

// TODO p2: This should be a FutureProvider as should all other context providers
final curUserAiChatThreadProvider =
    StreamProvider.autoDispose<AiChatThreadModel?>((ref) {
  return CurAuthDependencyProvider.watchStream(
    ref: ref,
    builder: (userId) {
      final watchedCurOrgId = ref.watch(curSelectedOrgIdNotifierProvider);

      if (watchedCurOrgId == null) {
        return Stream.value(null);
      }

      return ref
          .watch(aiChatThreadsRepositoryProvider)
          .watchUserThread(userId: userId, orgId: watchedCurOrgId);
    },
  );
});
