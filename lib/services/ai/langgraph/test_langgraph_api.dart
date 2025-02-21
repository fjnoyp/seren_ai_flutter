

import 'package:seren_ai_flutter/services/ai_interaction/langgraph/langgraph_api.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_ai_base_message_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_ai_chat_message_role.dart';
import 'package:seren_ai_flutter/services/ai_interaction/langgraph/models/lg_input_model.dart';



/*

curl --request POST \
  --url http://localhost:8123/threads/c55a9029-ef0b-4160-b0d5-bce5e0930be2/runs/stream \
  --header 'Content-Type: application/json' \
  --data '{  
  "assistant_id": "07265b79-da09-4093-9f39-158867182e18",
  "input": {
    "messages": [
      {
        "role": "user",
        "content": "what is my name"
      }
    ]
  },
  "stream_mode": "updates" 
}'

*/

Future<void> testLanggraphClientMethods() async {
  final client = createLanggraphClient();
  const threadId = 'c55a9029-ef0b-4160-b0d5-bce5e0930be2';
  const assistantId = "07265b79-da09-4093-9f39-158867182e18";

  //await streamRunExample('testing, please call getShiftInfo', client, threadId, assistantId);

  // Uncomment to test other methods
  // await testGetThreadRuns(client);
  // await testCreateThread(client);
  // await testCreateAssistant(client);
  // await testGetThreadState(client, threadId);
}



LanggraphApi createLanggraphClient() {
  return LanggraphApi(
    apiKey: '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', // Replace with your actual API key
    baseUrl: 'http://localhost:8123', // Replace with your actual base URL
  );
}

Future<void> streamRunExample(String content, LanggraphApi client, String threadId, String assistantId) async {  
  try {
  Stream<LgAiBaseMessageModel> messageStream = client.streamRun(
    threadId: threadId, 
    assistantId: assistantId, 
    streamMode: "updates",    
    input: LgAgentStateModel(
      messages: [
        LgInputMessageModel(role: LgAiChatMessageRole.user, content: content)
      ]
    )
  );
  
  await for (final message in messageStream) {
    // Handle each message as it comes in
    print("message: ${message.toString()}");
  }
} catch (e) {
  // This will catch both stream errors and timeout exceptions
  print('Stream error: $e');
}
}

Future<void> testGetThreadRuns(LanggraphApi client) async {
  try {
    final runs = await client.getThreadRuns('3ea75a49-76fe-45b3-b31d-43b22f40f613');
    print('Thread runs: $runs');
  } catch (e) {
    print('Error getting thread runs: $e');
  }
}

Future<void> testCreateThread(LanggraphApi client) async {
  try {
    final newThreadId = await client.createThread();
    print('Created new thread with ID: $newThreadId');
  } catch (e) {
    print('Error creating thread: $e');
  }
}

// Future<void> testCreateAssistant(LanggraphApi client) async {
//   try {
//     final assistantId = await client.createAssistant(
//       name: "My Assistant",
//       config: {
//         'configurable': {
//           'org_id': '123',
//           'user_id': '456',
//         }
//       },
//       metadata: {}, // Optional
//       ifExists: "raise", // Or "update" or "return_existing"
//     );
//     print('Created assistant with ID: $assistantId');
//   } catch (e) {
//     print('Error creating assistant: $e');
//   }
// }

Future<void> testGetThreadState(LanggraphApi client, String threadId) async {
  try {
    final threadState = await client.getThreadState(threadId);
    print('Thread state: $threadState');
  } catch (e) {
    print('Error getting thread state: $e');
  }
}