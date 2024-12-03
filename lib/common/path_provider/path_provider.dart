import 'path_provider_stub.dart'
    if (dart.library.io) 'path_provider_native.dart'
    if (dart.library.html) 'path_provider_web.dart';

abstract class PathProvider {
  Future<String> getTemporaryPath();

  Future<String> getApplicationSupportPath();  

  Future<String> getDownloadsPath();

  Future<String> getApplicationDocumentsPath();

  static PathProvider getPathProviderFactory() => getPathProvider();
}