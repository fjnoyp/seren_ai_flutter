import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Provides a singleton instance of the speech to text service.
final speechToTextServiceProvider = Provider<SpeechToTextService>((ref) {
  return SpeechToTextService();
});


enum SpeechToTextStateEnum {
  startListening,
  startNotListening,
  listening,
  notListening,
  done,
  available
}

/// Wraps the speech to text service and provides a simple interface for starting and stopping speech recognition.
class SpeechToTextService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool get isListening => _speechToText.isListening;

  Function(SpeechToTextStateEnum speechToTextState)?
      onSpeechToTextStateListener;
  Function(String status)? onErrorListener;

  String _language = Platform.localeName;

  set language(String language) => _language = language;

  /// Initializes the speech recognition service.
  Future<bool> init() async {
    if (!_isInitialized) {
      _isInitialized = await _speechToText.initialize(
        onError: (error) => _errorListener(error),
        onStatus: (status) => _statusListener(status),
      );
    }
    return _isInitialized;
  }

  /// Starts listening for speech input and converts it to text.
  /// [onResult] is called with the recognized text.
  /// [onSoundLevel] is called with the sound level.
  /// [listenFor] and [pauseFor] allow configuring the listening behavior.
  void start({
    required Function(String text) onResult,
    required Function(double level) onSoundLevel,
    Duration listenFor = const Duration(seconds: 60),
    Duration pauseFor = const Duration(seconds: 6),
  }) {
    onSpeechToTextStateListener?.call(SpeechToTextStateEnum.startListening);

    _speechToText.listen(
      onResult: (SpeechRecognitionResult result) =>
          onResult(result.recognizedWords),
      listenFor: listenFor,
      pauseFor: pauseFor,
      onSoundLevelChange: (double level) => onSoundLevel(level),
      localeId: _language,
    );
  }

  /// Stops listening for speech input.
  Future<void> stop() async {
    if (_speechToText.isListening) {
      onSpeechToTextStateListener
          ?.call(SpeechToTextStateEnum.startNotListening);
      await _speechToText.stop();
    }
  }

  void _errorListener(SpeechRecognitionError error) {
    onErrorListener?.call(error.errorMsg);
  }

  var prevStatus = '';
  void _statusListener(String status) {
    print(status);

    if (prevStatus == status) {
      return;
    }
    prevStatus = status;

    final speechState = _statusToSpeechState(status);
    onSpeechToTextStateListener?.call(speechState);
  }

  SpeechToTextStateEnum _statusToSpeechState(String status) {
    switch (status) {
      case 'listening':
        return SpeechToTextStateEnum.listening;
      case 'notListening':
        return SpeechToTextStateEnum.notListening;
      case 'done':
        return SpeechToTextStateEnum.done;
      case 'available':
        return SpeechToTextStateEnum.available;
      case 'startListening':
        return SpeechToTextStateEnum.startListening;
      case 'startNotListening':
        return SpeechToTextStateEnum.startNotListening;
      default:
        throw Exception('Unknown status: $status');
    }
  }
}
