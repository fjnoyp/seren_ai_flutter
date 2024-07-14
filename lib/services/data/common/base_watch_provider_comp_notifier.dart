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
    final watchedValue = ref.watch<T?>(watchedProvider);

    if (watchedValue == null) {
      _stateNotifier?.dispose();
      state = null;
      return;
    }

    final depInitValue = watchedValue;

    state = [];
    _stateNotifier?.dispose();
    _stateNotifier = createWatchingNotifier(depInitValue);
    _stateNotifier?.addListener((value) {
      state = value;
    });
  }

  @override
  void dispose() {
    _stateNotifier?.dispose();
    super.dispose();
  }
}
