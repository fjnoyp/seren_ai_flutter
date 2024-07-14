import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/services/data/common/base_listener_database_notifier.dart';

// TODO: we should likely remove this class and use BaseListenerDatabaseNotifier directly
// We can check curAuthUserProvider and just throw exception 
// Because we shouldn't be routed to any other page without curAuthUser anyway ... 
class BaseListenerOnCurAuthUserNotifier<K> extends StateNotifier<List<K>>{
  final Ref ref;
  BaseListenerDatabaseNotifier<K>? _baseNotifier;

  final List<K> initValue;
  final BaseListenerDatabaseNotifier<K> Function(String) setupDatabaseNotifier;

  BaseListenerOnCurAuthUserNotifier(this.ref, {required this.initValue, required this.setupDatabaseNotifier}) : super(initValue) {

    _init();
  }

  void _init() {
    // Use watch, listen does not do init state 
    ref.listen(curAuthUserProvider, (previous, next) {
      if (next == null) {
        state = initValue;
        _baseNotifier = null;
      } else {
        _setupDatabaseNotifier(next.id);
      }
    });
  }

  void _setupDatabaseNotifier(String userId) {
    _baseNotifier = setupDatabaseNotifier(userId); 

    _baseNotifier?.addListener((value) {
      state = value;
    });
  }

}