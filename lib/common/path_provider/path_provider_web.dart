// lib/services/data/path/path_service_web.dart
import 'package:seren_ai_flutter/common/path_provider/path_provider.dart';

class PathProviderWeb extends PathProvider {
  @override
  Future<String> getTemporaryPath() async => 'web-temp';

  @override
  Future<String> getApplicationSupportPath() async => 'web-support';

  @override
  Future<String> getDownloadsPath() async => 'downloads';

  @override
  Future<String> getApplicationDocumentsPath() async => 'documents';
}

PathProvider getPathProvider() => PathProviderWeb();