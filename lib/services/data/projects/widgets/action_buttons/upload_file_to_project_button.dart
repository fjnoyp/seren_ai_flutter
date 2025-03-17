import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai/ai_file_helper/widgets/ai_file_analysis_view.dart';
import 'package:seren_ai_flutter/services/data/projects/file_upload_type_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_files_service_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

          try {
            await ref.read(projectFilesServiceProvider.notifier).uploadFiles(
                  files,
                  projectId: projectId,
                  type: FileUploadType.temporary,
                );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Files uploaded successfully')),
            );

            // Process all uploaded files
            if (files.isNotEmpty && context.mounted) {
              // Create a list of file info maps with URLs
              final fileInfoList = files.map((file) {
                final fileName = file.name;
                final fileUrl = Supabase.instance.client.storage
                    .from('project_files')
                    .getPublicUrl(
                        '$projectId/${FileUploadType.temporary.directoryName}/$fileName');

                return {
                  'fileName': fileName,
                  'fileUrl': fileUrl,
                };
              }).toList();

              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: Container(
                    width: 700,
                    height: 500,
                    padding: const EdgeInsets.all(16),
                    child: AiTaskIdentificationView(
                      files: fileInfoList,
                      projectId: projectId,
                    ),
                  ),
                ),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Upload failed: ${e.toString()}')),
            );
          }
        }
      },
      icon: const Icon(Icons.upload_file),
      label: const Text('Upload file'),
    );
  }
}
