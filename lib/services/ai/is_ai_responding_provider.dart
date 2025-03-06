import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks whether the AI is currently processing a response
final isAiRespondingProvider = StateProvider<bool>((ref) => false);
