// lib/services/data/path/path_service_native.dart
import 'package:path_provider/path_provider.dart';
import 'package:seren_ai_flutter/common/path_provider/path_provider.dart';

class PathProviderNative extends PathProvider {
  @override
  Future<String> getTemporaryPath() async {
    final dir = await getTemporaryDirectory();
    return dir.path;
  }

  @override
  Future<String> getApplicationSupportPath() async {
    final dir = await getApplicationSupportDirectory();
    return dir.path;
  }

  @override
  Future<String> getDownloadsPath() async {
    final dir = await getDownloadsDirectory();
    return dir?.path ?? (await getApplicationSupportDirectory()).path;
  }

  @override 
  Future<String> getApplicationDocumentsPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

}

PathProvider getPathProvider() => PathProviderNative();