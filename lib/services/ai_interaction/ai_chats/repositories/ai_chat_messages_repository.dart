import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/repositories/ai_chat_queries.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';

final aiChatMessagesRepositoryProvider =
    Provider<AiChatMessagesRepository>((ref) {
  return AiChatMessagesRepository(ref.watch(dbProvider));
});

class AiChatMessagesRepository extends BaseRepository<AiChatMessageModel> {
  static const int defaultPageSize = 40;

  const AiChatMessagesRepository(super.db,
      {super.primaryTable = 'ai_chat_messages'});

  @override
  AiChatMessageModel fromJson(Map<String, dynamic> json) {
    return AiChatMessageModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(AiChatMessageModel item) {
    return item.toJson();
  }

  Stream<List<AiChatMessageModel>> watchThreadMessages({
    required String threadId,
    int limit = defaultPageSize,
    int offset = 0,
  }) {
    return watch(
      AiChatQueries.getThreadMessages,
      {
        'thread_id': threadId,
        'limit': limit,
        'offset': offset,
      },
    );
  }

  Future<List<AiChatMessageModel>> getThreadMessages({
    required String threadId,
    int limit = defaultPageSize,
    int offset = 0,
  }) async {
    return get(
      AiChatQueries.getThreadMessages,
      {
        'thread_id': threadId,
        'limit': limit,
        'offset': offset,
      },
    );
  }
}
