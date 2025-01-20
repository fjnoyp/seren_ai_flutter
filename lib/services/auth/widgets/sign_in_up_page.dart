import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignInUpPage extends ConsumerWidget {
  const SignInUpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            // TODO p5: maybe add seren logo here on top instead of the app bar
            child: SupaEmailAuth(
              onSignInComplete: (response) {
                ref
                    .read(navigationServiceProvider)
                    .navigateToWithReplacement(AppRoutes.home.name);
              },
              onSignUpComplete: (response) async {
                if (response.user != null && response.user!.email != null) {
                  final user = response.user!;

                  await Supabase.instance.client
                      .rpc('create_initial_setup_for_user', params: {
                    'auth_user_id': user.id,
                    'email': user.email!,
                    'first_name':
                        user.userMetadata?['first_name']?.trim() ?? '',
                    'last_name': user.userMetadata?['last_name']?.trim() ?? '',
                  });

                  await ref.read(curUserProvider.notifier).updateUser(user);

                  ref
                      .read(navigationServiceProvider)
                      .navigateToWithReplacement(AppRoutes.home.name);
                }
              },
              metadataFields: [
                MetaDataField(
                  prefixIcon: const Icon(Icons.person),
                  label: AppLocalizations.of(context)!.firstName,
                  key: 'first_name',
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return AppLocalizations.of(context)!.pleaseEnterSomething;
                    }
                    return null;
                  },
                ),
                MetaDataField(
                  prefixIcon: const Icon(Icons.person),
                  label: AppLocalizations.of(context)!.lastName,
                  key: 'last_name',
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return AppLocalizations.of(context)!.pleaseEnterSomething;
                    }
                    return null;
                  },
                ),
                BooleanMetaDataField(
                  key: 'terms_agreement',
                  isRequired: true,
                  checkboxPosition: ListTileControlAffinity.leading,
                  richLabelSpans: [
                    TextSpan(
                        text: AppLocalizations.of(context)!
                            .iHaveReadAndAgreeToThe),
                    TextSpan(
                      text: AppLocalizations.of(context)!.termsAndConditions,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          ref
                              .read(navigationServiceProvider)
                              .navigateTo(AppRoutes.termsAndConditions.name);
                        },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
