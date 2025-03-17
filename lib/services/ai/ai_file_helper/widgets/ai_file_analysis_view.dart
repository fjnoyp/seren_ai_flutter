import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai/ai_file_helper/ai_file_context_helper_provider.dart';

// TEMPORARY - this is a temporary view to identify tasks from a file
// TODO p1: update to actual task generation view
class AiTaskIdentificationView extends HookConsumerWidget {
  final List<Map<String, String>> files;
  final String projectId;

  const AiTaskIdentificationView({
    super.key,
    required this.files,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileCount = files.length;
    final isSingleFile = fileCount == 1;
    final fileName = isSingleFile
        ? files.first['fileName'] ?? 'file'
        : files.map((f) => f['fileName']).join(', ');

    final tasksFuture = useMemoized(() {
      if (isSingleFile) {
        return ref.read(aiFileContextHelperProvider).generateTasksFromFile(
              fileUrl: files.first['fileUrl']!,
              fileName: files.first['fileName']!,
              projectId: projectId,
            );
      } else {
        return ref
            .read(aiFileContextHelperProvider)
            .generateTasksFromMultipleFiles(
              files: files,
              projectId: projectId,
            );
      }
    });

    final snapshot = useFuture(tasksFuture);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tasks Identified from $fileName',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (!isSingleFile)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  files.map((f) => f['fileName']).join(', '),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (snapshot.hasData)
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(snapshot.data!),
                ),
              )
            else if (snapshot.hasError)
              Text('Error identifying tasks: ${snapshot.error}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error))
            else
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Analyzing file(s) to identify tasks...'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
