import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai/ai_context_helper/ai_context_helper_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

class AiContextView extends HookConsumerWidget {
  final String uniqueId;
  final Future<String> Function() summaryGenerator;
  final String loadingText;
  final String errorText;

  const AiContextView({
    super.key,
    required this.uniqueId,
    required this.summaryGenerator,
    this.loadingText = 'Generating AI summary...',
    this.errorText = 'Failed to generate summary',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use hooks for managing state
    final refreshCounter = useState(0);
    final summaryFuture = useMemoized(summaryGenerator, [refreshCounter.value]);
    final snapshot = useFuture(summaryFuture);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'AI Context',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => refreshCounter.value++,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                if (snapshot.hasData) {
                  return Text(snapshot.data!);
                }
                if (snapshot.hasError) {
                  return Text(
                    errorText,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  );
                }
                return Center(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(loadingText),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Example usage widgets that implement the specific summary types:

class AIContextTaskOverview extends ConsumerWidget {
  final String taskId;
  final String? additionalInstructions;
  const AIContextTaskOverview({
    super.key,
    required this.taskId,
    this.additionalInstructions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AiContextView(
      uniqueId: 'task_overview_$taskId',
      summaryGenerator: () => ref
          .read(aiContextHelperProvider)
          .getTaskOverviewSummary(taskId,
              additionalInstructions: additionalInstructions),
    );
  }
}

class AIContextTaskList extends ConsumerWidget {
  final List<TaskModel> tasks;
  final String? additionalInstructions;
  const AIContextTaskList({
    super.key,
    required this.tasks,
    this.additionalInstructions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AiContextView(
      uniqueId: 'task_list_${tasks.length}',
      summaryGenerator: () => ref
          .read(aiContextHelperProvider)
          .getTaskListHighlightsSummary(tasks,
              additionalInstructions: additionalInstructions),
    );
  }
}
