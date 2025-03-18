import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_search_modal.dart';

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
      onTap: isWebVersion
          ? () => ref
              .read(navigationServiceProvider)
              .showPopupDialog(const _TaskSearchDialog())
          : () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => DraggableScrollableSheet(
                  initialChildSize: 1,
                  builder: (context, _) => const TaskSearchModal(),
                ),
              ),
    );
  }
}

class _TaskSearchDialog extends ConsumerWidget {
  const _TaskSearchDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Material(
          elevation: 16,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: size.width * 0.5,
              maxHeight: size.height * 0.8,
            ),
            child: const TaskSearchModal(),
          ),
        ),
      ),
    );
  }
}
