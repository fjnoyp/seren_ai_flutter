import 'package:flutter_riverpod/flutter_riverpod.dart';

// Since we still don't use any complex state management logic,
// we can just use a simple state provider to store the currently selected task id.
final curSelectedTaskIdStateProvider = StateProvider<String?>((ref) => null);
