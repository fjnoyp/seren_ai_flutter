import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai/ai_context_helper/ai_context_helper_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

class AiContextAnchorButton extends ConsumerWidget {
  final String uniqueId;
  final Future<String> Function() summaryGenerator;
  final String loadingText;
  final String errorText;

  const AiContextAnchorButton({
    super.key,
    required this.uniqueId,
    required this.summaryGenerator,
    this.loadingText = 'Generating AI summary...',
    this.errorText = 'Failed to generate summary',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MenuAnchor(
      crossAxisUnconstrained: false,
      menuChildren: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: AiContextView(
            uniqueId: uniqueId,
            summaryGenerator: summaryGenerator,
            loadingText: loadingText,
            errorText: errorText,
          ),
        ),
      ],
      builder: (context, controller, child) => OutlinedButton(
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset('assets/images/AI button.svg',
                width: 24, height: 24),
            const SizedBox(width: 8),
            const Text('AI Context'),
          ],
        ),
      ),
    );
  }
}

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
            const Text(
              'AI Context',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                if (snapshot.hasData) {
                  return SelectableText(snapshot.data!);
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
    return AiContextAnchorButton(
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
    return AiContextAnchorButton(
      uniqueId: 'task_list_${tasks.length}',
      summaryGenerator: () => ref
          .read(aiContextHelperProvider)
          .getTaskListHighlightsSummary(tasks,
              additionalInstructions: additionalInstructions),
    );
  }
}
