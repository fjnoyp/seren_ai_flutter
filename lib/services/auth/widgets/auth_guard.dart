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
      // Redirect to sign-in page if user is not authenticated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(context, signInUpRoute, (route) => false);
      });
      return Container(); // Return an empty container while redirecting
    }

    return child;
  }
}