//import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:seren_ai_flutter/common/path_provider/path_provider.dart';
import 'package:seren_ai_flutter/common/utils/string_extension.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:seren_ai_flutter/common/platform/url_launcher.dart';

final noteAttachmentsServiceProvider =
    NotifierProvider<NoteAttachmentsService, List<String>>(
        () => NoteAttachmentsService());

class NoteAttachmentsService extends Notifier<List<String>> {
  @override
  List<String> build() {
    return [];
  }

  final supabaseStorage = Supabase.instance.client.storage;
  final pathProvider = PathProvider.getPathProviderFactory();

  Future<void> fetchNoteAttachments({required String noteId}) async {
    final attachments =
        await supabaseStorage.from('note_attachments').list(path: noteId);
    attachments.removeWhere((e) => e.name.startsWith('.'));

    final noteAttachmentUrls = attachments
        .map((e) => supabaseStorage
            .from('note_attachments')
            .getPublicUrl('$noteId/${e.name}'))
        .toList();

    state = noteAttachmentUrls;
  }

  Future<void> uploadAttachments(
    List<XFile> files, {
    required String noteId,
  }) async {
    for (var file in files) {
      XFile fileToUpload = file;
      String fileName = kIsWeb ? file.name : file.path.getFilePathName();

      // Only compress if it's an image
      if (fileName.toLowerCase().endsWith('.jpg') ||
          fileName.toLowerCase().endsWith('.jpeg') ||
          fileName.toLowerCase().endsWith('.png')) {
        try {
          final bytes = await fileToUpload.readAsBytes();
          final compressedBytes = await FlutterImageCompress.compressWithList(
            bytes,
            quality: 65,
          );

          fileToUpload = XFile.fromData(compressedBytes, name: fileName);

          // Update filename to .jpg extension if needed
          if (!fileName.toLowerCase().endsWith('.jpg')) {
            fileName =
                '${fileName.substring(0, fileName.lastIndexOf('.'))}.jpg';
          }
        } catch (e) {
          // Handle compression error
          print('Error compressing image: $e');
        }
      }

      await supabaseStorage.from('note_attachments').uploadBinary(
            '$noteId/$fileName',
            await fileToUpload.readAsBytes(),
            fileOptions: const FileOptions(upsert: true),
          );
    }

    fetchNoteAttachments(noteId: noteId);
  }

  Future<Uint8List> getAttachmentBytes({
    required String fileUrl,
    required String noteId,
  }) async {
    return await supabaseStorage
        .from('note_attachments')
        .download('$noteId/${fileUrl.getFilePathName()}');
  }

  Future<bool> openAttachmentLocally({
    required String fileUrl,
    required String noteId,
  }) async {
    if (kIsWeb) {
      // For web, open in new tab or trigger download
      final url = supabaseStorage
          .from('note_attachments')
          .getPublicUrl('$noteId/${fileUrl.getFilePathName()}');

      UrlLauncher.downloadFile(url, fileUrl.getFilePathName());
      return true;
    }

    // For native platforms, create temporary file and open
    final bytes = await getAttachmentBytes(fileUrl: fileUrl, noteId: noteId);
    //final tempDir = await pathProvider.getTemporaryPath();
    final tempFile = XFile.fromData(bytes, name: fileUrl.getFilePathName());

    await OpenFile.open(tempFile.path);
    return true;
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

  Future<void> deleteAllAttachments({
    required String noteId,
  }) async {
    final attachments =
        await supabaseStorage.from('note_attachments').list(path: noteId);
    attachments.removeWhere((e) => e.name.startsWith('.'));

    await supabaseStorage
        .from('note_attachments')
        .remove(attachments.map((e) => '$noteId/${e.name}').toList());

    state = [];
  }
}
