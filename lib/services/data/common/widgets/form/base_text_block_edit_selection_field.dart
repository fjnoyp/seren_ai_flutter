import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/color_animation.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/selection_field.dart';

class BaseTextBlockEditSelectionField extends HookConsumerWidget {
  final bool isEditable;
  final ProviderListenable<String?> descriptionProvider;
  final Function(WidgetRef, String?) updateDescription;
  final Widget? labelWidget;
  final String? hintText;

  const BaseTextBlockEditSelectionField({
    super.key,
    required this.isEditable,
    required this.descriptionProvider,
    required this.updateDescription,
    this.labelWidget,
    this.hintText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curDescription = ref.watch(descriptionProvider);
    final controller = useTextEditingController(text: curDescription);

    final colorAnimation = useAiActionColorAnimation(
      context,
      ref,
      triggerValue: curDescription,
    );

    return isWebVersion && isEditable
        ? AnimatedBuilder(
            animation: colorAnimation.colorTween,
            builder: (context, _) {
              controller.text = curDescription ?? '';
              return TextFormField(
                controller: controller,
                minLines: 1,
                maxLines: null,
                decoration: InputDecoration(
                  hintText:
                      hintText ?? AppLocalizations.of(context)!.enterTextHere,
                  prefixIcon: labelWidget,
                  filled: false,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none,
                ),
                onFieldSubmitted: (value) async {
                  await updateDescription(ref, value);
                },
                onTapOutside: (event) async {
                  await updateDescription(ref, controller.text);
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              );
            })
        : AnimatedSelectionField<String>(
            labelWidget: labelWidget ?? const Icon(Icons.description),
            validator: (description) => null,
            // description == null || description.isEmpty
            //     ? AppLocalizations.of(context)!.textIsRequired
            //     : null,
            valueToString: (description) =>
                description ?? AppLocalizations.of(context)!.enterText,
            enabled: isEditable,
            value: curDescription?.isEmpty ?? true ? hintText : curDescription,
            onValueChanged: updateDescription,
            onTap: isWebVersion
                ? (_) async => null
                : (BuildContext context) async {
                    FocusManager.instance.primaryFocus?.unfocus();
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
                    FocusManager.instance.primaryFocus?.unfocus();
                    return null;
                  },
          );
  }
}

class TextBlockWritingModal extends HookWidget {
  final String initialDescription;
  final Function(WidgetRef, String) onDescriptionChanged;
  final String? label;

  const TextBlockWritingModal({
    super.key,
    required this.initialDescription,
    required this.onDescriptionChanged,
    this.label,
  });

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
            if (label != null)
              Text(
                label!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 16),
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
                onPressed: () async {
                  // if we don't use await here, eventual confirmation dialogs don't show up
                  await onDescriptionChanged(ref, descriptionController.text);
                  ref.read(navigationServiceProvider).pop();
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
