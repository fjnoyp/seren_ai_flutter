import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/file_upload_type_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_files_service_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UploadFileToProjectButton extends ConsumerWidget {
  const UploadFileToProjectButton(this.projectId, {super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      onPressed: () async {
        final result = await FilePicker.platform.pickFiles();

        if (result != null && result.files.isNotEmpty) {
          XFile file;
          if (kIsWeb) {
            // On web, use bytes and name only
            file = XFile.fromData(
              result.files.first.bytes!,
              name: result.files.first.name,
            );
          } else {
            // On native platforms, use file path
            file = XFile(
              result.files.first.path!,
              name: result.files.first.name,
            );
          }

          try {
            await ref.read(projectFilesServiceProvider.notifier).uploadFiles(
              [file],
              projectId: projectId,
              type: FileUploadType.temporary,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      AppLocalizations.of(context)?.fileUploadedSuccessfully ??
                          'File uploaded successfully')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      '${AppLocalizations.of(context)?.fileUploadFailed ?? 'Upload failed'}: ${e.toString()}')),
            );
          }
        }
      },
      icon: const Icon(Icons.upload_file),
      label: Text(AppLocalizations.of(context)?.uploadFile ?? 'Upload file'),
    );
  }
}
