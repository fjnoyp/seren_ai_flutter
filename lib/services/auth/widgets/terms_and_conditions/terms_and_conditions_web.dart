import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class TermsAndConditionsView extends StatelessWidget {
  const TermsAndConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Register view factory
    final String viewId = 'terms-and-conditions-view';
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = 'https://seren-ai.framer.website/terms'
        ..style.border = 'none'
        ..style.height = '100%'
        ..style.width = '100%';
      return iframe;
    });

    return Scaffold(
      body: HtmlElementView(viewType: viewId),
    );
  }
}