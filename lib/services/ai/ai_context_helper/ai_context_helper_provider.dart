// Prepares messages to send to the ai

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/language_provider.dart';
import 'package:seren_ai_flutter/services/ai/ai_chat_service_provider.dart';
import 'package:seren_ai_flutter/services/ai/ai_context_helper/ai_summary_cache_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_comments_repository.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';
import 'package:seren_ai_flutter/services/notifications/repositories/push_notifications_repository.dart';

enum AiSummaryType {
  taskOverview,
  taskListHighlights,
}

final aiContextHelperProvider = Provider<AiContextHelper>((ref) {
  return AiContextHelper(ref: ref);
});

class AiContextHelper {
  final Ref ref;

  AiContextHelper({required this.ref});

  String _getSystemMessageWithLanguage(
      String baseMessage, String? additionalInstructions) {
    final language = ref.read(languageSNP);
    return '''
Please respond in the language: $language. 
$baseMessage${additionalInstructions != null ? '\n$additionalInstructions' : ''}
''';
  }

  Future<String> _sendAiRequest({
    required String systemBaseMessage,
    required String userMessage,
    String? additionalInstructions,
  }) async {
    final aiService = ref.read(aiChatServiceProvider);
    final messages = await aiService.sendSingleCallMessageToAi(
      systemMessage: _getSystemMessageWithLanguage(
          systemBaseMessage, additionalInstructions),
      userMessage: userMessage,
    );
    return messages.first.content;
  }

  Future<String> getTaskOverviewSummary(String taskId,
      {String? additionalInstructions}) async {
    final tasksRepo = ref.read(tasksRepositoryProvider);
    final commentsRepo = ref.read(taskCommentsRepositoryProvider);
    final usersRepo = ref.read(usersRepositoryProvider);

    // Get task details
    final task = await tasksRepo.getById(taskId);
    if (task == null) {
      throw Exception('Task not found');
    }

    // Get task comments
    final comments = await commentsRepo.getTaskComments(taskId: taskId);

    // Generate cache key
    final cacheKey = generateTaskOverviewCacheKey(
      taskId,
      task.updatedAt,
      comments.map((c) => c.updatedAt).toList(),
    );

    // Check cache
    final cachedSummary =
        ref.read(aiSummaryCacheProvider(cacheKey).notifier).get();
    if (cachedSummary != null) {
      return cachedSummary;
    }

    // Get task assignees
    final assignees = await usersRepo.getTaskAssignedUsers(taskId: taskId);

    // Format data for AI
    final formattedData = {
      'task': {
        'name': task.name,
        'description': task.description,
        'status': task.status?.name,
        'priority': task.priority?.name,
        'dueDate': task.dueDate?.toIso8601String(),
        'createdAt': task.createdAt?.toIso8601String(),
      },
      'assignees':
          assignees.map((u) => '${u.firstName} ${u.lastName}').toList(),
      'comments': comments
          .map((c) => {
                'content': c.content,
                'createdAt': c.createdAt?.toIso8601String(),
              })
          .toList(),
    };

    // Generate new summary
    final summary = await _sendAiRequest(
      systemBaseMessage:
          'Generate a concise and compact summary to be displayed in a small UI card for users to quickly understand important details about the task and its current status. Only provide summary no other text. The users can see the task list below in the UI so you do not need to restate obvious details. Generate a max of 4-6 sentences preferably 1-2.',
      userMessage: 'Summarize: ${formattedData}',
      additionalInstructions: additionalInstructions,
    );

    // Cache the result
    ref.read(aiSummaryCacheProvider(cacheKey).notifier).set(summary);

    return summary;
  }

  Future<String> getTaskListHighlightsSummary(List<TaskModel> tasks,
      {String? additionalInstructions}) async {
    final usersRepo = ref.read(usersRepositoryProvider);

    // Generate cache key
    final cacheKey = generateTaskListCacheKey(tasks);

    // Check cache
    final cachedSummary =
        ref.read(aiSummaryCacheProvider(cacheKey).notifier).get();
    if (cachedSummary != null) {
      return cachedSummary;
    }

    // Format tasks for AI, only including relevant fields
    final formattedTasks = await Future.wait(tasks.map((task) async {
      final assignees = await usersRepo.getTaskAssignedUsers(taskId: task.id);
      return {
        'name': task.name,
        'status': task.status?.name,
        'priority': task.priority?.name,
        'dueDate': task.dueDate?.toIso8601String(),
        'assignees': assignees.map((u) => u.email).toList(),
      };
    }));

    // Generate new summary
    final summary = await _sendAiRequest(
      systemBaseMessage:
          'Generate a concise and compact summary to be displayed in a small UI card for users to quickly understand important details about the list of tasks and the current status. Focus on highlighting key patterns, urgent items, and overall progress. Only provide summary no other text. The users can see the task list below in the UI so you do not need to restate obvious details. Generate a max of 4-6 sentences preferably 1-2.',
      userMessage: 'Summarize: ${formattedTasks}',
      additionalInstructions: additionalInstructions,
    );

    // Cache the result
    ref.read(aiSummaryCacheProvider(cacheKey).notifier).set(summary);

    return summary;
  }

  Future<String> getDailyNotificationsSummary(DateTime date,
      {String? additionalInstructions}) async {
    final pushNotificationsRepo = ref.read(pushNotificationsRepositoryProvider);

    // Generate cache key
    final cacheKey = generateDailyNotificationsCacheKey(date);

    // Check cache
    final cachedSummary =
        ref.read(aiSummaryCacheProvider(cacheKey).notifier).get();
    if (cachedSummary != null) {
      return cachedSummary;
    }

    // Get notifications for the specified day
    final startOfDay =
        DateTime(date.year, date.month, date.day).toLocal().copyWith(hour: 0);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Get notifications for the day
    final notifications =
        await pushNotificationsRepo.getNotificationsForDateRange(
      startDate: startOfDay,
      endDate: endOfDay,
    );

    log.info(
        'got ${notifications.length} notifications between $startOfDay and $endOfDay');

    if (notifications.isEmpty) {
      return "No notable activities for this day.";
    }

    // Format notifications for AI
    final formattedNotifications = notifications
        .map((notification) => notification.toAiReadableMap())
        .toList();

    // Generate new summary
    final summary = await _sendAiRequest(
      systemBaseMessage:
          'Generate a concise and informative summary of the day\'s activities based on the notifications. MOST IMPORTANTLY, highlight any task status updates or changes. Then focus on other key events, task updates, and important changes. The summary should be well-structured and easy to read. Organize related activities together when possible.',
      userMessage: 'Summarize the day\'s activities: $formattedNotifications',
      additionalInstructions: additionalInstructions,
    );

    // Cache the result
    ref.read(aiSummaryCacheProvider(cacheKey).notifier).set(summary);

    return summary;
  }
}
