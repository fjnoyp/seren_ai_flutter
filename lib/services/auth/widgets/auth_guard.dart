import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';

/// Ensure user authenticated or redirect to signInUp page
class AuthGuard extends ConsumerWidget {
  final Widget child;

  const AuthGuard({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(curAuthUserProvider);

    if (user == null) {
      // TODO: replace with some runtime logic instead of just waiting 3 seconds
      Future.delayed(const Duration(seconds: 3)).then(
        (_) {
          if (user == null) {
            // Redirect to sign-in page if user is not authenticated
            Navigator.of(context)
                .pushNamedAndRemoveUntil(signInUpRoute, (route) => false);
            return Container(); // Return an empty container while redirecting
          }
        },
      );
    }

    return child;
  }
}
