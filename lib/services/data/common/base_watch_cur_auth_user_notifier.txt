import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/services/data/common/base_watch_provider_comp_notifier.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

class BaseWatchCurAuthUserNotifier<K> extends BaseWatchProviderCompNotifier<UserModel, K> {
  BaseWatchCurAuthUserNotifier(
    super.ref, {    
    required super.createWatchingNotifier,
  }) : super(
          watchedProvider: curAuthUserProvider,
        );
}