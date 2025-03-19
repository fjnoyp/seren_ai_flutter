import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai/ai_chat_service_provider.dart';

final aiFileContextHelperProvider = Provider<AiFileContextHelper>((ref) {
  return AiFileContextHelper(ref: ref);
});

class AiFileContextHelper {
  final Ref ref;

  AiFileContextHelper({required this.ref});

  Future<String> generateTasksFromFile({
    required String fileUrl,
    required String fileName,
    required String projectId,
  }) async {
    try {
      // TODO p1: update prompt to task for actual task generation instead of just identifying tasks
      final userMessage = '''
Please analyze the file available at this URL: $fileUrl
Filename: $fileName
Project id: $projectId

Based on the content of this file, identify a list of potential tasks that should be created.
IMPORTANT: Only suggest tasks that are directly supported by the file content. Do not hallucinate or invent tasks that aren't clearly indicated by the code or comments.

For each task:
1. Provide a clear, concise task title
2. Include a detailed description that references specific parts of the file
3. Suggest a reasonable due date if applicable
4. Indicate a priority level (Low, Medium, High)

Format your response as a numbered list of tasks.
''';

      final aiService = ref.read(aiChatServiceProvider);
      final messages = await aiService.sendSingleCallMessageToAi(
        systemMessage:
            'You are an expert at analyzing files and extracting actionable tasks from their content.',
        userMessage: userMessage,
      );

      return messages.first.content;
    } catch (e) {
      return 'Failed to identify tasks: ${e.toString()}';
    }
  }
}
