import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class SignInUpPage extends StatelessWidget {
  const SignInUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SupaEmailAuth(
              onSignInComplete: (response) {
                Navigator.of(context).pushReplacementNamed(homeRoute);
              },
              onSignUpComplete: (response) {
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
              ],
            )
          ],
        ),
      ),
    );
  }
}
