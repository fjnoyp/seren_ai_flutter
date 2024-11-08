
import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_type.dart';
import 'package:seren_ai_flutter/services/data/shifts/shift_tool_methods.dart';

var aiMessagesResults = [
  AiChatMessageModel(
    content: "I'm good how about you? I am an ai assistant meant to help you with your shift info",
    type: AiChatMessageType.ai,
    parentChatThreadId: '',
  ),
];


var aiRequestResults = [
  AiChatMessageModel(
    content: "Sure let me look for your shift info for you",
    type: AiChatMessageType.ai,
    parentChatThreadId: '',
  ),
  ShiftInfoResultModel(
    message: 'Current shift time ranges message for ai',
    showOnly: false, 
    activeShiftRanges: [
      DateTimeRange(start: DateTime.now(), end: DateTime.now().add(const Duration(hours: 8))),
    ],
  ),
  ShiftClockInOutResultModel(
    message: 'Clocked In',
    showOnly: false,
    clockedIn: true,
  ),
];
