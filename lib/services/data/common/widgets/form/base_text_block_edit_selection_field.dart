import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/selection_field.dart';

class BaseTextBlockEditSelectionField extends ConsumerWidget {
  final bool enabled;
  final ProviderListenable<String?> descriptionProvider;
  final Function(WidgetRef, String?) updateDescription;

  const BaseTextBlockEditSelectionField({
    super.key,
    required this.enabled,
    required this.descriptionProvider,
    required this.updateDescription,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curDescription = ref.watch(descriptionProvider);

    return AnimatedSelectionField<String>(
      labelWidget: const Icon(Icons.description),
      validator: (description) => null,
      // description == null || description.isEmpty
      //     ? AppLocalizations.of(context)!.textIsRequired
      //     : null,
      valueToString: (description) => description ?? AppLocalizations.of(context)!.enterText,
      enabled: enabled,
      value: curDescription,      
      onValueChanged: updateDescription,
      showSelectionModal: (BuildContext context) async {
         showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return TextBlockWritingModal(
              initialDescription: curDescription ?? '',
              onDescriptionChanged: updateDescription,
            );
          },
        );
      },
    );
  }
}

class TextBlockWritingModal extends HookWidget {
  final String initialDescription;
  final void Function(WidgetRef, String) onDescriptionChanged;

  const TextBlockWritingModal({
    Key? key,
    required this.initialDescription,
    required this.onDescriptionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final descriptionController =
        useTextEditingController(text: initialDescription);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enterTextHere,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Consumer(builder: (context, ref, child) {
              return ElevatedButton(
                onPressed: () {
                onDescriptionChanged(ref, descriptionController.text);
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.save),
              );
            }),
          ],
        ),
      ),
    );
  }
}
