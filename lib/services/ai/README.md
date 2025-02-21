# AI Interaction Flow 

ai_chat_service_provider.dart
- sends message 
- displays ai result

ai_result
- ai message or result from executing an ai_request
- an ai_chat_message can contain an ai_request 

ai_request execution 
- executed by ai_request_executor.dart
- returns a list of ai_request_result

