import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seren_ai_flutter/common/utils/string_extension.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final noteAttachmentsServiceProvider =
    NotifierProvider<NoteAttachmentsService, List<String>>(
        () => NoteAttachmentsService());

class NoteAttachmentsService extends Notifier<List<String>> {
  @override
  List<String> build() {
    return [];
  }

  // Needed in case of reset
  List<String> _initialNoteAttachmentUrls = [];
  final supabaseStorage = Supabase.instance.client.storage;

  Future<void> fetchNoteAttachments({
    bool firstLoad = false,
    required String noteId,
  }) async {
    final attachments =
        await supabaseStorage.from('note_attachments').list(path: noteId);
    attachments.removeWhere((e) => e.name.startsWith('.'));

    final noteAttachmentUrls = attachments
        .map((e) => supabaseStorage
            .from('note_attachments')
            .getPublicUrl('$noteId/${e.name}'))
        .toList();

    if (firstLoad) {
      _initialNoteAttachmentUrls = noteAttachmentUrls;
    }

    state = noteAttachmentUrls;
  }

  Future<void> uploadAttachments(
    List<File> files, {
    required String noteId,
  }) async {
    for (var file in files) {
      await supabaseStorage.from('note_attachments').upload(
            '$noteId/${file.path.getFilePathName()}',
            file,
            fileOptions: const FileOptions(upsert: true),
          );
    }
    fetchNoteAttachments(noteId: noteId);
  }

  Future<void> removeUnuploadedAttachments(String noteId) async {
    final attachmentsToRemove =
        await supabaseStorage.from('note_attachments').list(path: noteId);
    attachmentsToRemove.removeWhere((e) => _initialNoteAttachmentUrls
        .any((url) => e.name == url.getFilePathName()));

    if (attachmentsToRemove.isNotEmpty) {
      await supabaseStorage
          .from('note_attachments')
          .remove(attachmentsToRemove.map((e) => '$noteId/${e.name}').toList());
    }
  }

  Future<bool> openAttachmentLocally({
    required String fileUrl,
    required String noteId,
  }) async {
    final file = await createOrGetLocalFile(noteId, fileUrl);

    await OpenFile.open(file.path);
    return true;
  }

  Future<File> createOrGetLocalFile(String noteId, String fileUrl) async {
    final path = await getDownloadsDirectory();
    // Create the noteId directory if it doesn't exist
    final noteDir = Directory('${path?.path}/$noteId');
    await noteDir.create(recursive: true);

    final file = File('${path?.path}/$noteId/${fileUrl.getFilePathName()}');
    if (!(await _isFileVersionFetched(
        fileUrl: fileUrl, file: file, noteId: noteId))) {
      final fileBytes = await supabaseStorage
          .from('note_attachments')
          .download('$noteId/${fileUrl.getFilePathName()}');
      await file.writeAsBytes(fileBytes);
    }
    return file;
  }

  Future<bool> _isFileVersionFetched({
    required String fileUrl,
    required File file,
    required String noteId,
  }) async {
    if (file.existsSync()) {
      final lastModified = await file.lastModified();

      final files =
          await supabaseStorage.from('note_attachments').list(path: noteId);
      final onlineFile =
          files.firstWhere((f) => f.name == fileUrl.getFilePathName());
      final onlineLastModified = DateTime.parse(onlineFile.updatedAt!);

      return lastModified.isAfter(onlineLastModified);
    }
    return false;
  }

  Future<void> deleteAttachment({
    required String fileUrl,
    required String noteId,
  }) async {
    await supabaseStorage
        .from('note_attachments')
        .remove(['$noteId/${fileUrl.getFilePathName()}']);
    fetchNoteAttachments(noteId: noteId);
  }
}
