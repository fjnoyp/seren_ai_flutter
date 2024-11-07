
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/langgraph_service.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';

final langgraphServiceProvider = Provider<LanggraphService>((ref) {
  final db = ref.watch(dbProvider);
  return LanggraphService(db: db);
});
