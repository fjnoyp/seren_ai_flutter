import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/text_to_speech/text_to_speech_service.dart';

final textToSpeechServiceProvider =
    NotifierProvider<TextToSpeechService, TextToSpeechStateEnum>(() {
  return TextToSpeechService();
});
