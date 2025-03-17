import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/path_provider/path_provider.dart';
import 'package:seren_ai_flutter/common/utils/string_extension.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final projectFilesServiceProvider =
    NotifierProvider<ProjectFilesService, List<String>>(
        () => ProjectFilesService());

class ProjectFilesService extends Notifier<List<String>> {
  @override
  List<String> build() {
    return [];
  }

  final supabaseStorage = Supabase.instance.client.storage;
  final pathProvider = PathProvider.getPathProviderFactory();

  Future<void> uploadFiles(
    List<XFile> files, {
    required String projectId,
  }) async {
    for (var file in files) {
      final fileName = kIsWeb ? file.name : file.path.getFilePathName();

      await supabaseStorage.from('project_files').uploadBinary(
            '$projectId/$fileName',
            await file.readAsBytes(),
            fileOptions: const FileOptions(upsert: true),
          );
    }
  }
}
