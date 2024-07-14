import 'package:seren_ai_flutter/services/data/common/base_watch_provider_comp_notifier.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/cur_org_id_provider.dart';

class BaseWatchCurOrgNotifier<K> extends BaseWatchProviderCompNotifier<String?, K> {
  BaseWatchCurOrgNotifier(
    super.ref, {    
    required super.createWatchingNotifier,
  }) : super(
          watchedProvider: curOrgIdProvider,
        );
}