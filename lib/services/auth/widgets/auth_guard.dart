import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';

/// Ensure user authenticated or redirect to signInUp page
class AuthGuard extends ConsumerWidget {
  final Widget child;

  const AuthGuard({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(curAuthUserProvider);

    if (authState is LoggedOutAuthState || authState is ErrorAuthState) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(signInUpRoute, (route) => false);
      });
    }

    return switch (authState) {
      LoggedInAuthState() => child,
      LoadingAuthState() || InitialAuthState() => const Center(
          child: CircularProgressIndicator(),
        ),
      ErrorAuthState() || LoggedOutAuthState() => const SizedBox.shrink(),
    };
  }
}
