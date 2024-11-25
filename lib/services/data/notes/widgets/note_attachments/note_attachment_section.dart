import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
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
        if (Platform.isIOS) {
          if (await _getPermission()) {
            final fileType = await showModalBottomSheet<FileType>(
              context: context,
              builder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.image),
                    title: Text(AppLocalizations.of(context)!.images),
                    onTap: () => Navigator.pop(context, FileType.image),
                  ),
                  ListTile(
                    leading: const Icon(Icons.attach_file),
                    title: Text(AppLocalizations.of(context)!.files),
                    onTap: () => Navigator.pop(context, FileType.any),
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
    final result = await FilePicker.platform.pickFiles(
      type: type,
      allowMultiple: true,
    );
    
    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();
      ref.read(noteAttachmentsServiceProvider.notifier).uploadAttachments(
            files,
            noteId: ref.read(curNoteServiceProvider).curNoteId,
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
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(noteAttachmentsServiceProvider.notifier).deleteAttachment(
                  fileUrl: attachmentUrl,
                  noteId: ref.read(curNoteServiceProvider).curNoteId,
                );
            Navigator.pop(context);
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
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Center(
          child: switch (attachmentUrl.split('.').last) {
            'png' || 'jpg' || 'jpeg' => Image.network(
                attachmentUrl,
                loadingBuilder: (context, child, loadingProgress) =>
                    loadingProgress == null
                        ? child
                        : const Center(
                            child: CircularProgressIndicator(),
                          ),
              ),
            // TODO p2: add other file extensions preview
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
    );
  }
}
