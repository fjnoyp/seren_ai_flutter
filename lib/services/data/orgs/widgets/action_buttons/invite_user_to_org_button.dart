import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InviteUserToOrgButton extends ConsumerWidget {
  const InviteUserToOrgButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.person_add),
      onPressed: () {
        // TODO: implement a user invite system
      },
    );
  }
}
