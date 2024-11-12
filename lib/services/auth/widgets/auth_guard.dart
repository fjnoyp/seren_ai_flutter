import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';

/// Ensure user authenticated or redirect to signInUp page
class AuthGuard extends ConsumerWidget {
  final Widget child;

  const AuthGuard({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueHandlerWidget(
      value: ref.watch(curUserProvider),
      data: (user) => user == null ? const _NavigateToSignInUp() : child,
      error: (error, _) => const _NavigateToSignInUp(),
    );
  }
}

class _NavigateToSignInUp extends StatelessWidget {
  const _NavigateToSignInUp();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.signInUp.name, (route) => false);
    });
    return const SizedBox.shrink();
  }
}
