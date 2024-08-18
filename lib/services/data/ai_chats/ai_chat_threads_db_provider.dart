import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/base_table_db.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_thread_model.dart';

final aiChatThreadsDbProvider = Provider<BaseTableDb<AiChatThreadModel>>((ref) {
  return BaseTableDb<AiChatThreadModel>(
    db: ref.watch(dbProvider),
    tableName: 'ai_chat_threads',
    fromJson: (json) => AiChatThreadModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});
