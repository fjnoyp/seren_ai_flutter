import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_chat_service_provider.dart';

import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_listen_state_provider.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_service_provider.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_status_provider.dart';

final sttOrchestratorProvider = Provider((ref) {
  // Listen to the speech-to-text provider
  //var previousState = ref.read(speechProvider).speechState;
  // ISSUE: speechState can change a lot since it's updating with user voice changes
  // Thus we will get duplicate events for speech ....

  ref.listen<SpeechToTextStatusState>(speechToTextStatusProvider,
      (previousSpeechState, speechState) async {

        if(previousSpeechState?.speechState == speechState.speechState) {
          return;
        }


    print('received speech state: ${speechState.speechState}');

    // Stop tts if stt starts 
    if (speechState.speechState == SpeechToTextStateEnum.startListening) {
      /*
      final textToSpeech = ref.read(textToSpeechServiceProvider);
      await textToSpeech.stop();
      */
    }

    if (speechState.speechState == SpeechToTextStateEnum.startNotListening) {
      final speechText = ref.read(speechToTextListenStateProvider);

      if (speechText.text.isEmpty) {
        return;
      }

      print('received speech text: ${speechText.text}');

      await ref.read(aiChatServiceProvider).sendMessageToAi(speechText.text);


      // Enact AI action 
      /*
      final result = await ref
          .read(langchainNotifierProvider.notifier)
          .askConversation(speechText.text);
      */

      // Speak the result
      /* 
      final textToSpeech = ref.read(textToSpeechServiceProvider);
      await textToSpeech.speak(result);
      */
    }
  });
});

/*
Next Step: 

Converting text into a TODO 

Mapping the text into the fields of a TODO

Steps for AI: 
Write a prompt on what to do 

*/
