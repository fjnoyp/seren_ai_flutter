//import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/common/utils/string_extension.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/cur_note_service_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/note_attachments_service_provider.dart';

class NoteAttachmentSection extends ConsumerWidget {
  const NoteAttachmentSection(this.isEnabled, {super.key});

  final bool isEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16.0,
          children: [
            ...ref.watch(noteAttachmentsServiceProvider).map(
                (e) => _AttachmentPreviewButton(e, enableDelete: isEnabled)),
          ],
        ),
        if (isEnabled) const _AddAttachmentButton(),
      ],
    );
  }
}

class _AddAttachmentButton extends ConsumerWidget {
  const _AddAttachmentButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () async {
        if (UniversalPlatform.instance().isIOS) {
          if (await _getPermission()) {
            final fileType = await showModalBottomSheet<FileType>(
              context: context,
              builder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.image),
                    title: Text(AppLocalizations.of(context)!.images),
                    onTap: () => ref.read(navigationServiceProvider).pop(FileType.image),
                  ),
                  ListTile(
                    leading: const Icon(Icons.attach_file),
                    title: Text(AppLocalizations.of(context)!.files),
                    onTap: () => ref.read(navigationServiceProvider).pop(FileType.any),
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            );

            if (fileType != null) {
              await _pickAndUploadFile(ref, fileType);
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      AppLocalizations.of(context)!.photosPermissionDenied)),
            );
          }
        } else {
          await _pickAndUploadFile(ref, FileType.media);
        }
      },
      icon: const Icon(Icons.add),
      label: Text(AppLocalizations.of(context)!.addAttachment),
    );
  }

  Future<void> _pickAndUploadFile(WidgetRef ref, FileType type) async {
    // Define limits
    const int maxFileSizeBytes = 10485760; // 10MB
    const int maxFileCount = 5;

    final result = await FilePicker.platform.pickFiles(
      type: type,
      allowMultiple: true,
    );

    if (result != null) {
      if (result.files.length > maxFileCount) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(ref.context)!.tooManyFiles(maxFileCount)),
            backgroundColor: Theme.of(ref.context).colorScheme.error,
          ),
        );
      }

      // Filter valid files directly
      final validFiles = result.files.where((file) {
        if (file.size > maxFileSizeBytes) {
          ScaffoldMessenger.of(ref.context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(ref.context)!
                  .fileTooLarge(file.path!.getFilePathName())),
              backgroundColor: Theme.of(ref.context).colorScheme.error,
            ),
          );
          return false;
        }
        return true;
      }).take(maxFileCount);

      // Create File objects directly from valid PlatformFile objects
      List<XFile> files = validFiles.map((file) => XFile(file.path!)).toList();

      // Show a non-blocking loading snackbar
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(ref.context)!
                  .filesUploading(files.length)),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      // Upload files in a non-blocking way
      (
        ref.read(noteAttachmentsServiceProvider.notifier).uploadAttachments(
              files,
              noteId: ref.read(curNoteServiceProvider).curNoteId,
            ),
      );
    }
  }

  Future<bool> _getPermission() async {
    if (await Permission.storage.isGranted) {
      return true;
    } else if (await Permission.storage.isPermanentlyDenied) {
      await openAppSettings();
      return await Permission.storage.isGranted;
    } else {
      await Permission.photos.request();
      return await Permission.storage.isGranted;
    }
  }
}

class _AttachmentPreviewButton extends StatelessWidget {
  const _AttachmentPreviewButton(
    this.attachmentUrl, {
    required this.enableDelete,
  });

  final String attachmentUrl;
  final bool enableDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => _AttachmentPreview(attachmentUrl),
            ),
            // TODO p3: conditionally change the icon based on its file extension
            icon: const Icon(Icons.attach_file),
            label: Text(
              Uri.decodeFull(attachmentUrl).split('/').last,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (enableDelete)
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => _DeleteAttachmentDialog(attachmentUrl),
            ),
            icon: Icon(Icons.close, color: Theme.of(context).colorScheme.error),
          ),
      ],
    );
  }
}

class _DeleteAttachmentDialog extends ConsumerWidget {
  const _DeleteAttachmentDialog(this.attachmentUrl);

  final String attachmentUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      content: Text(AppLocalizations.of(context)!
          .deleteAttachment(Uri.decodeFull(attachmentUrl).split('/').last)),
      actions: [
        TextButton(
          onPressed: () => ref.read(navigationServiceProvider).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(noteAttachmentsServiceProvider.notifier).deleteAttachment(
                  fileUrl: attachmentUrl,
                  noteId: ref.read(curNoteServiceProvider).curNoteId,
                );
            ref.read(navigationServiceProvider).pop();
          },
          child: Text(AppLocalizations.of(context)!.delete),
        ),
      ],
    );
  }
}

class _AttachmentPreview extends ConsumerWidget {
  const _AttachmentPreview(this.attachmentUrl);

  final String attachmentUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create an ImageProvider that we can evict from cache
    final imageProvider = NetworkImage(attachmentUrl);

    return PopScope(
      // Using PopScope instead of GestureDetector for better cleanup
      onPopInvokedWithResult: (didPop, result) {
        // Clear the image from cache when closing
        imageProvider.evict().then((_) {
          // Force a garbage collection sweep (optional, use carefully)
          // ImageCache().clear();
          // PaintingBinding.instance.imageCache.clear();
        });
      },
      child: GestureDetector(
        onTap: () => ref.read(navigationServiceProvider).pop(),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Center(
            child: switch (attachmentUrl.split('.').last) {
              'png' || 'jpg' || 'jpeg' => Image(
                  image: imageProvider,
                  loadingBuilder: (context, child, loadingProgress) =>
                      loadingProgress == null
                          ? child
                          : const Center(
                              child: CircularProgressIndicator(),
                            ),
                  // Add error builder to handle failed loads
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                ),
              _ => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.notAbleToPreview,
                      textAlign: TextAlign.center,
                    ),
                    TextButton(
                      onPressed: () => ref
                          .read(noteAttachmentsServiceProvider.notifier)
                          .openAttachmentLocally(
                            fileUrl: attachmentUrl,
                            noteId: ref.read(curNoteServiceProvider).curNoteId,
                          ),
                      child: Text(AppLocalizations.of(context)!.openFile),
                    ),
                  ],
                ),
            },
          ),
        ),
      ),
    );
  }
}
