import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/widgets/debug/debug_state_modal.dart';

class DebugOpenModalButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.bug_report),
      onPressed: () => _showDebugModal(context, ref),
    );
  }

  void _showDebugModal(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const DebugStateModal(),
    );
  }
}
