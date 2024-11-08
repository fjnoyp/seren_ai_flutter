import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/repositories/ai_chat_queries.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';

final aiChatMessagesRepositoryProvider = Provider<AiChatMessagesRepository>((ref) {
  return AiChatMessagesRepository(ref.watch(dbProvider));
});

class AiChatMessagesRepository extends BaseRepository<AiChatMessageModel> {
  const AiChatMessagesRepository(super.db);

  @override
  Set<String> get watchTables => {'ai_chat_messages'};

  @override
  AiChatMessageModel fromJson(Map<String, dynamic> json) {
    return AiChatMessageModel.fromJson(json);
  }

  Stream<List<AiChatMessageModel>> watchThreadMessages({
    required String threadId,
  }) {
    return watch(
      AiChatQueries.getThreadMessages,
      {
        'thread_id': threadId,
      },
    );
  }

  Future<List<AiChatMessageModel>> getThreadMessages({
    required String threadId,
  }) async {
    return get(
      AiChatQueries.getThreadMessages,
      {
        'thread_id': threadId,
    });
  }
}
