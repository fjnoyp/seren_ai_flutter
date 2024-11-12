
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignInUpPage extends StatelessWidget {
  const SignInUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        // TODO: maybe add seren logo here on top instead of the app bar
        child: SupaEmailAuth(
          onSignInComplete: (response) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.home.name);
          },
          onSignUpComplete: (response) async {
            if (response.user != null && response.user!.email != null) {
              final user = response.user!;
              await Supabase.instance.client.from('users').insert(
                    UserModel(parentAuthUserId: user.id, email: user.email!)
                        .toJson()
                      ..addAll(
                        {
                          'created_at': DateTime.now().toIso8601String(),
                          'updated_at': DateTime.now().toIso8601String()
                        },
                      ),
                  );
            }
            Navigator.of(context).pushReplacementNamed(AppRoutes.home.name);
          },
          metadataFields: [
            MetaDataField(
              prefixIcon: const Icon(Icons.person),
              label: AppLocalizations.of(context)!.username,
              key: 'username',
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
                TextSpan(text: AppLocalizations.of(context)!.iHaveReadAndAgreeToThe),
                TextSpan(
                  text: AppLocalizations.of(context)!.termsAndConditions,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.pushNamed(context, AppRoutes.termsAndConditions.name);
                    },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
