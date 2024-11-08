import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart';
import 'package:seren_ai_flutter/services/data/common/base_table_db.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_thread_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/repositories/ai_chat_threads_repository.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/langgraph_api.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';

final aiChatThreadsServiceProvider = Provider<AiChatThreadsService>((ref) {
  return AiChatThreadsService(ref.watch(dbProvider));
});


class AiChatThreadsService extends BaseTableDb<AiChatThreadModel> {

  AiChatThreadsService(PowerSyncDatabase db)
      : super(
          db: db,
          tableName: 'ai_chat_threads',
          fromJson: AiChatThreadModel.fromJson,
          toJson: (item) => item.toJson(),
        );

  Future<({String? error, AiChatThreadModel? thread})> saveThread(AiChatThreadModel thread) async {
    try {
      await insertItem(thread);
      return (error: null, thread: thread);
    } catch (e) {
      return (error: e.toString(), thread: null);
    }
  }
}
