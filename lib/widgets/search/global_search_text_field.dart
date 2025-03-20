import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/widgets/search/search_modal.dart';
import 'package:seren_ai_flutter/services/ai/widgets/mobile_ai_assistant_button/mobile_overlay_container.dart';

// This widget is currently using [TaskSearchModal] for search.
// We shall switch to a global search as soon as we have one.
class GlobalSearchTextField extends ConsumerWidget {
  const GlobalSearchTextField({super.key, this.textAlign});

  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return TextField(
      canRequestFocus: false,
      textAlign: textAlign ?? TextAlign.center,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, size: 18),
        prefixIconColor: theme.colorScheme.outline,
        prefixIconConstraints:
            const BoxConstraints(minWidth: 36, minHeight: 18),
        hintText: AppLocalizations.of(context)!.search,
        hintStyle: TextStyle(color: theme.colorScheme.outline),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: false,
        isDense: true,
      ),
      onTap: () => showSearchModalDialog(context, ref),
    );
  }
}
