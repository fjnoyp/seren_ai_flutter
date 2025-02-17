import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import '../models/user_device_token_model.dart';

final userDeviceTokensRepositoryProvider =
    Provider<UserDeviceTokensRepository>((ref) {
  return UserDeviceTokensRepository(ref.watch(dbProvider));
});

class UserDeviceTokensRepository extends BaseRepository<UserDeviceTokenModel> {
  const UserDeviceTokensRepository(super.db,
      {super.primaryTable = 'user_device_tokens'});

  @override
  UserDeviceTokenModel fromJson(Map<String, dynamic> json) {
    return UserDeviceTokenModel.fromJson(json);
  }

  // method to get device token by deviceId and userId
  Future<UserDeviceTokenModel?> getDeviceTokenByDeviceIdAndUserId(
      {required String deviceId, required String userId}) async {
    final result = await get(
      'SELECT DISTINCT t.* FROM user_device_tokens t WHERE t.device_id = :device_id AND t.user_id = :user_id',
      {
        'device_id': deviceId,
        'user_id': userId,
      },
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }
}
