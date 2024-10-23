import 'package:flutter_tts/flutter_tts.dart';

enum TextToSpeechStateEnum { speaking, ready }

class TextToSpeechService {
  final flutterTts = FlutterTts();

  TextToSpeechStateEnum textToSpeechState = TextToSpeechStateEnum.ready;

  // TODO: I can't call this once, but must call it every time ... don't know why
  // If it's called at start of app that's not enough ...
  Future<void> init() async {
    flutterTts.awaitSpeakCompletion(true);

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
    await init();

    flutterTts.setVolume(1.0);
    flutterTts.setSpeechRate(.5);
    flutterTts.setPitch(.8);

    textToSpeechState = TextToSpeechStateEnum.speaking;
    await flutterTts.speak(text);

    textToSpeechState = TextToSpeechStateEnum.ready;
  }

  Future<void> stop() async {
    await init();

    await flutterTts.stop();

    textToSpeechState = TextToSpeechStateEnum.ready;
  }
}
