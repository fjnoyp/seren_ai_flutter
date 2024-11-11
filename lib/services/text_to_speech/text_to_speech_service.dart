import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';

enum TextToSpeechStateEnum { speaking, ready }

class TextToSpeechService {
  TextToSpeechService() {
    _init();
  }

  final flutterTts = FlutterTts();

  TextToSpeechStateEnum textToSpeechState = TextToSpeechStateEnum.ready;
  String _language = Platform.localeName;

  set language(String language) => _language = language;

  // TODO: I can't call this once, but must call it every time ... don't know why
  // If it's called at start of app that's not enough ...
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

    textToSpeechState = TextToSpeechStateEnum.speaking;
    await flutterTts.speak(text);

    textToSpeechState = TextToSpeechStateEnum.ready;
  }

  Future<void> stop() async {
    await flutterTts.stop();

    textToSpeechState = TextToSpeechStateEnum.ready;
  }
}
