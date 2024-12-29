import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/repositories/ai_chat_queries.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_thread_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';

final aiChatThreadsRepositoryProvider =
    Provider<AiChatThreadsRepository>((ref) {
  return AiChatThreadsRepository(ref.watch(dbProvider));
});

class AiChatThreadsRepository extends BaseRepository<AiChatThreadModel> {
  const AiChatThreadsRepository(super.db);

  @override
  Set<String> get REMOVEwatchTables => {'ai_chat_threads'};

  @override
  AiChatThreadModel fromJson(Map<String, dynamic> json) {
    return AiChatThreadModel.fromJson(json);
  }

  Stream<AiChatThreadModel?> watchUserThread({
    required String userId,
    required String orgId,
  }) {
    return watch(
      AiChatQueries.getUserThread,
      {
        'user_id': userId,
        'org_id': orgId,
      },
    ).map((threads) => threads.isEmpty ? null : threads.first);
  }

  Future<AiChatThreadModel?> getUserThread({
    required String userId,
    required String orgId,
  }) async {
    return get(
      AiChatQueries.getUserThread,
      {
        'user_id': userId,
        'org_id': orgId,
      },
    ).then((threads) => threads.isEmpty ? null : threads.first);
  }
}
