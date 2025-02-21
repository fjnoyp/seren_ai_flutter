import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/ai/ai_chat_service_provider.dart';
import 'speech_to_text_service_provider.dart';

final speechToTextListenStateProvider = StateNotifierProvider<
    SpeechToTextListenStateNotifier, SpeechToTextListenState>((ref) {
  final speechService = ref.read(speechToTextServiceProvider);
  return SpeechToTextListenStateNotifier(speechService);
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

class SpeechToTextListenStateNotifier
    extends StateNotifier<SpeechToTextListenState> {
  final SpeechToTextService _speechService;

  SpeechToTextListenStateNotifier(this._speechService)
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

  void resumeListening() {
    final currentText = state.text;

    _speechService.start(onResult: (text) {
      state = state.copyWith(text: currentText + text);
    }, onSoundLevel: (soundLevel) {
      state = state.copyWith(soundLevel: soundLevel);
    });
  }

  Future<void> sendText(WidgetRef ref) async {
    await _speechService.stop();
    await ref.read(aiChatServiceProvider).sendMessageToAi(state.text);
    state = state.copyWith(text: '');
  }
}
