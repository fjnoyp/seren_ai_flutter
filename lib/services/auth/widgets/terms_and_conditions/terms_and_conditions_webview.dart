import 'package:flutter/material.dart';
import 'terms_and_conditions_native.dart' if (dart.library.html) 'terms_and_conditions_web.dart';

class TermsAndConditionsWebview extends StatelessWidget {
  const TermsAndConditionsWebview({super.key});

  @override
  Widget build(BuildContext context) {
    return const TermsAndConditionsView();
  }
}