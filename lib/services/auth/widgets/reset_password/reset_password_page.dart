import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResetPasswordPage extends ConsumerWidget {
  const ResetPasswordPage(this.accessToken, {super.key});

  final String? accessToken;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: SupaResetPassword(
              accessToken: accessToken,
              onSuccess: (response) => Navigator.pop(context),
              localization: SupaResetPasswordLocalization(
                enterPassword: AppLocalizations.of(context)!.enterPassword,
                passwordLengthError: AppLocalizations.of(context)!.passwordLengthError,
                updatePassword: AppLocalizations.of(context)!.updatePassword,
                unexpectedError: AppLocalizations.of(context)!.unexpectedError,
                passwordResetSent: AppLocalizations.of(context)!.passwordResetSent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
