//import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
enum TextToSpeechStateEnum { speaking, ready }

class TextToSpeechService extends Notifier<TextToSpeechStateEnum> {
  @override
  TextToSpeechStateEnum build() {
    _init();
    return TextToSpeechStateEnum.ready;
  }

  final flutterTts = FlutterTts();

  String _language = UniversalPlatform.instance().localeName;

  set language(String language) => _language = language;

  Future<void> _init() async {
    flutterTts.awaitSpeakCompletion(true);
    await flutterTts.setLanguage(_language);

    // ios only initialization
    await flutterTts.setSharedInstance(true);
    await flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker
        ],
        IosTextToSpeechAudioMode.defaultMode);
  }

  Future<void> speak(String text) async {
    await flutterTts.stop();

    flutterTts.setVolume(1.0);
    flutterTts.setSpeechRate(.5);
    flutterTts.setPitch(.8);

    state = TextToSpeechStateEnum.speaking;
    await flutterTts.speak(text);

    state = TextToSpeechStateEnum.ready;
  }

  Future<void> stop() async {
    await flutterTts.stop();

    state = TextToSpeechStateEnum.ready;
  }
}
