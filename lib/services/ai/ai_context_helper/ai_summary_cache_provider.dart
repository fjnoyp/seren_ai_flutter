import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:async';

/// Cache key generator for single task overview
String generateTaskOverviewCacheKey(
    String taskId, DateTime? lastUpdatedAt, List<DateTime?> commentUpdatedAts) {
  final buffer = StringBuffer();
  buffer.write(taskId);
  buffer.write('_');
  buffer.write(lastUpdatedAt?.toIso8601String() ?? 'null');
  for (final commentDate in commentUpdatedAts) {
    buffer.write('_');
    buffer.write(commentDate?.toIso8601String() ?? 'null');
  }

  final bytes = utf8.encode(buffer.toString());
  return sha256.convert(bytes).toString();
}

/// Cache key generator for task list
String generateTaskListCacheKey(List<TaskModel> tasks) {
  final buffer = StringBuffer();
  for (final task in tasks) {
    buffer.write(task.id);
    buffer.write('_');
    buffer.write(task.updatedAt?.toIso8601String() ?? 'null');
    buffer.write(';');
  }

  final bytes = utf8.encode(buffer.toString());
  return sha256.convert(bytes).toString();
}

String generateDailyNotificationsCacheKey(DateTime date) {
  final dateString = '${date.year}-${date.month}-${date.day}';
  return 'daily_notifications_summary_$dateString';
}

class AiSummaryCacheEntry extends StateNotifier<String?> {
  Timer? _timer;
  final Ref ref;

  AiSummaryCacheEntry(this.ref) : super(null) {
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    // Issue is that we don't know when a cached item will never be used because the underlying data was updated ...
    // Thus a very high number, could cause too many items in cache
    // But lower numbers increase chance cache invalidates before a valid item would actually be used again ...
    // NOTE - ai context users a different ai model that can be tracked separately from the more expensive tool calling ai chat model
    _timer = Timer(const Duration(minutes: 20), () {
      ref.invalidateSelf();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String? get() {
    if (state != null) {
      _startTimer(); // Renew timer on access
    }
    return state;
  }

  void set(String value) {
    state = value;
    _startTimer(); // Renew timer on set
  }
}

/// Cache for AI generated summaries
final aiSummaryCacheProvider = StateNotifierProvider.autoDispose
    .family<AiSummaryCacheEntry, String?, String>((ref, cacheKey) {
  ref.keepAlive();
  return AiSummaryCacheEntry(ref);
});
