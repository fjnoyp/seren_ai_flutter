import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_files_service_provider.dart';

class UploadFileToProjectButton extends ConsumerWidget {
  const UploadFileToProjectButton(this.projectId, {super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      onPressed: () async {
        final result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
        );

        if (result != null && result.files.isNotEmpty) {
          final files = result.files.map((file) {
            if (kIsWeb) {
              // On web, use bytes and name only
              return XFile.fromData(
                file.bytes!,
                name: file.name,
              );
            } else {
              // On native platforms, use file path
              return XFile(
                file.path!,
                name: file.name,
              );
            }
          }).toList();

          await ref
              .read(projectFilesServiceProvider.notifier)
              .uploadFiles(files, projectId: projectId);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Files uploaded successfully')),
          );
        }
      },
      icon: const Icon(Icons.upload_file),
      label: const Text('Upload file'),
    );
  }
}
