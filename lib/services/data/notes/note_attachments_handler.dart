import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final noteAttachmentsHandlerProvider =
    NotifierProvider<NoteAttachmentsHandler, List<String>>(
        () => NoteAttachmentsHandler());

class NoteAttachmentsHandler extends Notifier<List<String>> {
  @override
  List<String> build() {
    return [];
  }

  // Needed in case of reset
  List<String> _initialNoteAttachmentUrls = [];
  final supabaseStorage = Supabase.instance.client.storage;
  String _fileName(String filePath) => Uri.decodeFull(filePath).split('/').last;

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
            '$noteId/${_fileName(file.path)}',
            file,
            fileOptions: const FileOptions(upsert: true),
          );
    }
    fetchNoteAttachments(noteId: noteId);
  }

  Future<void> removeUnuploadedAttachments(String noteId) async {
    final attachmentsToRemove =
        await supabaseStorage.from('note_attachments').list(path: noteId);
    attachmentsToRemove.removeWhere((e) =>
        _initialNoteAttachmentUrls.any((url) => e.name == _fileName(url)));

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
    final file = await _createOrGetLocalFile(noteId, fileUrl);

    if (!(await _isFileVersionFetched(
        fileUrl: fileUrl, file: file, noteId: noteId))) {
      final fileBytes = await supabaseStorage
          .from('note_attachments')
          .download('$noteId/${_fileName(fileUrl)}');
      await file.writeAsBytes(fileBytes);
    }
    await OpenFile.open(file.path);
    return true;
  }

  Future<File> _createOrGetLocalFile(String noteId, String fileUrl) async {
    final path = await getDownloadsDirectory();
    // Create the noteId directory if it doesn't exist
    final noteDir = Directory('${path?.path}/$noteId');
    await noteDir.create(recursive: true);
    
    final file = File('${path?.path}/$noteId/${_fileName(fileUrl)}');
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
      final onlineFile = files.firstWhere((f) => f.name == _fileName(fileUrl));
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
        .remove(['$noteId/${_fileName(fileUrl)}']);
    fetchNoteAttachments(noteId: noteId);
  }
}
