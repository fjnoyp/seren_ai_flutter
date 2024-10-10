import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_listen_state_provider.dart';
import 'speech_to_text_service_provider.dart';

/// Provides a status notifier for the speech to text service.
final speechToTextStatusProvider =
    NotifierProvider<SpeechToTextStatusNotifier, SpeechToTextStatusState>(
        SpeechToTextStatusNotifier.new);

class SpeechToTextStatusState {
  final bool isInitialized;
  final SpeechToTextStateEnum speechState;
  final String error;

  SpeechToTextStatusState(
      {this.isInitialized = false,
      this.speechState = SpeechToTextStateEnum.notListening,
      this.error = ''});

  SpeechToTextStatusState copyWith(
      {bool? isInitialized,
      SpeechToTextStateEnum? speechState,
      String? error}) {
    return SpeechToTextStatusState(
      isInitialized: isInitialized ?? this.isInitialized,
      speechState: speechState ?? this.speechState,
      error: error ?? this.error,
    );
  }
}

class SpeechToTextStatusNotifier extends Notifier<SpeechToTextStatusState> {
  late final SpeechToTextService _speechService;

  @override
  SpeechToTextStatusState build() {
    _speechService = ref.read(speechToTextServiceProvider);
    init();
    return SpeechToTextStatusState();
  }

  Future<void> init() async {
    final isInitialized = await _speechService.init();
    if (isInitialized) {
      state = SpeechToTextStatusState(isInitialized: true);
    } else {
      state = SpeechToTextStatusState(
          isInitialized: false, error: 'Failed to initialize');
    }

    _speechService.onSpeechToTextStateListener = (speechState) {
      state = state.copyWith(speechState: speechState);
    };
  }
}