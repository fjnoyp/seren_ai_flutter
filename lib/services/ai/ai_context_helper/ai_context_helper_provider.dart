// Prepares messages to send to the ai

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/language_provider.dart';
import 'package:seren_ai_flutter/services/ai/ai_chat_service_provider.dart';
import 'package:seren_ai_flutter/services/ai/ai_context_helper/ai_summary_cache_provider.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/models/requests/ai_action_request_model.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/models/requests/ai_info_request_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_comments_repository.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';

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
          'Generate a very concise and compact summary to be displayed in a small UI card for users to quickly understand important details about the task and its current status. Only provide summary no other text.',
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
          'Generate a very concise and compact summary to be displayed in a small UI card for users to quickly understand important details about the list of tasks and the current status. Focus on highlighting key patterns, urgent items, and overall progress. Only provide summary no other text.',
      userMessage: 'Summarize: ${formattedTasks}',
      additionalInstructions: additionalInstructions,
    );

    // Cache the result
    ref.read(aiSummaryCacheProvider(cacheKey).notifier).set(summary);

    return summary;
  }
}
