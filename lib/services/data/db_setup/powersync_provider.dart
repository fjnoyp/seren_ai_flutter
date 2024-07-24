// Override the provider to allow for future initialization
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart';

final powerSyncProvider = Provider<PowerSyncDatabase>((ref) {
  throw UnimplementedError();
});