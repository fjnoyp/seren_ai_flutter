import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart';
import 'package:seren_ai_flutter/services/data/common/z_base_table_db.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';

final aiChatMessagesServiceProvider = Provider<AiChatMessagesService>((ref) {
  return AiChatMessagesService(ref.watch(dbProvider));
});

class AiChatMessagesService extends BaseTableDb<AiChatMessageModel> {
  AiChatMessagesService(PowerSyncDatabase db)
      : super(
          db: db,
          tableName: 'ai_chat_messages',
          fromJson: AiChatMessageModel.fromJson,
          toJson: (item) => item.toJson(),
        );

  Future<({String? error})> saveMessage(AiChatMessageModel message) async {
    try {
      await insertItem(message);
      return (error: null);
    } catch (e) {
      return (error: e.toString());
    }
  }

  Future<({String? error})> saveMessages(
      List<AiChatMessageModel> messages) async {
    try {
      for (final message in messages) {
        await insertItem(message);
      }
      return (error: null);
    } catch (e) {
      return (error: e.toString());
    }
  }
}
