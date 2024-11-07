// You might also want to add these type definitions
enum LgAiChatMessageRole {
  ai,
  user,
  tool,
}

extension LgAiChatMessageRoleExtension on LgAiChatMessageRole {
  String toRawString() {
    return name; // Returns 'ai', 'tool', or 'user'
  }
}