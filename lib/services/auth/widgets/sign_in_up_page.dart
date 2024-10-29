import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class SignInUpPage extends StatelessWidget {
  const SignInUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          SupaEmailAuth(
            onSignInComplete: (response) {
              Navigator.of(context).pushReplacementNamed(homeRoute);
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
              Navigator.of(context).pushReplacementNamed(homeRoute);
            },
            metadataFields: [
              MetaDataField(
                prefixIcon: const Icon(Icons.person),
                label: 'Username',
                key: 'username',
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter something';
                  }
                  return null;
                },
              ),
              BooleanMetaDataField(
                key: 'terms_agreement',
                isRequired: true,
                checkboxPosition: ListTileControlAffinity.leading,
                richLabelSpans: [
                  const TextSpan(text: 'I have read and agree to the '),
                  TextSpan(
                    text: 'Terms and Conditions',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushNamed(context, termsAndConditionsRoute);
                      },
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
