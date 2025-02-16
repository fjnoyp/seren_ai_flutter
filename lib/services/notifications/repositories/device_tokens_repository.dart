import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import '../models/device_token_model.dart';

final deviceTokensRepositoryProvider = Provider<DeviceTokensRepository>((ref) {
  return DeviceTokensRepository(ref.watch(dbProvider));
});

class DeviceTokensRepository extends BaseRepository<DeviceTokenModel> {
  const DeviceTokensRepository(super.db,
      {super.primaryTable = 'user_device_tokens'});

  @override
  DeviceTokenModel fromJson(Map<String, dynamic> json) {
    return DeviceTokenModel.fromJson(json);
  }
}
