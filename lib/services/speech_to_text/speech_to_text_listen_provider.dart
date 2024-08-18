import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'speech_to_text_service_provider.dart';




final speechToTextListenProvider =
    StateNotifierProvider<SpeechToTextListenNotifier, SpeechToTextListenState>(
        (ref) {
  final speechService = ref.read(speechToTextServiceProvider);
  return SpeechToTextListenNotifier(speechService);
});

class SpeechToTextListenState {
  final String text;
  final double soundLevel;

  SpeechToTextListenState({this.text = '', this.soundLevel = 0.0});

  copyWith({String? text, double? soundLevel}) {
    return SpeechToTextListenState(
      text: text ?? this.text,
      soundLevel: soundLevel ?? this.soundLevel,
    );
  }
}

class SpeechToTextListenNotifier
    extends StateNotifier<SpeechToTextListenState> {
  final SpeechToTextService _speechService;

  SpeechToTextListenNotifier(this._speechService)
      : super(SpeechToTextListenState());

  void startListening() {
    state = SpeechToTextListenState();

    _speechService.start(
      onResult: (text) {
        state = state.copyWith(text: text);
      },
      onSoundLevel: (soundLevel) {
        state = state.copyWith(soundLevel: soundLevel);
      },
    );
  }

  Future<void> stopListening() async {
    await _speechService.stop();
  }

  Future<void> cancelListening() async {
    state = state.copyWith(text: '');
    await _speechService.stop();
  }
}
