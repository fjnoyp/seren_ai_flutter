import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/base_table_db.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';

final aiChatMessagesDbProvider = Provider<BaseTableDb<AiChatMessageModel>>((ref) {
  return BaseTableDb<AiChatMessageModel>(
    db: ref.watch(dbProvider),
    tableName: 'ai_chat_messages',
    fromJson: (json) => AiChatMessageModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});
