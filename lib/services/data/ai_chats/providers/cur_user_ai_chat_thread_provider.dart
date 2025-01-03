import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_thread_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/repositories/ai_chat_threads_repository.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_org_dependency_provider.dart';

// TODO p2: This should be a NotifierProvider<AsyncValue<AiChatThreadModel?>>
final curUserAiChatThreadProvider =
    StreamProvider.autoDispose<AiChatThreadModel?>((ref) {
  return CurAuthDependencyProvider.watchStream(
    ref: ref,
    builder: (userId) {
      final watchedCurOrgId = ref.watch(curOrgIdProvider);

      if(watchedCurOrgId == null) {
        return Stream.value(null);
      }

      return ref
          .watch(aiChatThreadsRepositoryProvider)
          .watchUserThread(userId: userId, orgId: watchedCurOrgId);
    },
  );
});
