import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_state_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_states.dart';

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
            ...(ref.watch(curNoteStateProvider) as LoadedCurNoteState)
                .joinedNote
                .attachmentUrls
                .map((e) =>
                    _AttachmentPreviewButton(e, enableDelete: isEnabled)),
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
        FilePickerResult? result =
            await FilePicker.platform.pickFiles(allowMultiple: true);

        if (result != null) {
          List<File> files = result.paths.map((path) => File(path!)).toList();

          ref.read(curNoteStateProvider.notifier).uploadAttachments(files);
        }
      },
      icon: const Icon(Icons.add),
      label: const Text('Add Attachment'),
    );
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
        OutlinedButton.icon(
          onPressed: () => showDialog(
            context: context,
            builder: (context) => _AttachmentPreview(attachmentUrl),
          ),
          // TODO: conditionally change the icon based on its file extension
          icon: const Icon(Icons.attach_file),
          label: Text(Uri.decodeFull(attachmentUrl).split('/').last),
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
      content: Text('Delete ${Uri.decodeFull(attachmentUrl).split('/').last}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            ref
                .read(curNoteStateProvider.notifier)
                .deleteAttachment(attachmentUrl);
            Navigator.pop(context);
          },
          child: const Text('Delete'),
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
    return SizedBox(
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
          // TODO: add other file extensions preview
          _ => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Not able to preview this file.\n You can try opening it locally.',
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: () => ref
                      .read(curNoteStateProvider.notifier)
                      .openAttachmentLocally(attachmentUrl),
                  child: const Text('Open file'),
                ),
              ],
            ),
        },
      ),
    );
  }
}
