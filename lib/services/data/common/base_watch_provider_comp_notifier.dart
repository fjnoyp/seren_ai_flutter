import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Create a notifier that initializes based on another provider
class BaseWatchProviderCompNotifier<T, K> extends StateNotifier<List<K>?> {
  final Ref ref;
  StateNotifier<List<K>>? _stateNotifier;

  final StateNotifier<List<K>> Function(T) createWatchingNotifier;
  final StateNotifierProvider<StateNotifier<T?>, T?> watchedProvider;

  BaseWatchProviderCompNotifier(
    this.ref, {
    required this.createWatchingNotifier,
    required this.watchedProvider,
  }) : super(null) {
    _init();
  }

  void _init() {

    // DO NOT USE ref.watch - this causes provider to dispose and rebuild when watched value changes 
    ref.listen<T?>(watchedProvider, (previous, next) {
      if (next == null) {
        _stateNotifier?.dispose();
        state = null;
        return;
      }

      state = [];
      _stateNotifier?.dispose();
      _stateNotifier = createWatchingNotifier(next);
      _stateNotifier?.addListener((value) {
        state = value;
      });
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _stateNotifier?.dispose();
    super.dispose();
  }
}
