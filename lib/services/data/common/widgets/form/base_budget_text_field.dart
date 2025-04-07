import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:seren_ai_flutter/common/currency_provider.dart';
import 'package:seren_ai_flutter/services/data/budget/budget_item_field_enum.dart';
import 'package:seren_ai_flutter/services/data/budget/models/budget_item_ref_model.dart';
import 'package:seren_ai_flutter/services/data/budget/providers/cur_org_available_budget_items.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/color_animation.dart';
import 'package:intl/intl.dart';

class BaseBudgetTextField extends HookConsumerWidget {
  const BaseBudgetTextField({
    super.key,
    required this.isEditable,
    required this.valueProvider,
    required this.updateValue,
    this.numbersOnly = false,
    this.formatAsCurrency = false,
  });

  final bool isEditable;
  final ProviderListenable<String> valueProvider;
  final Future Function(WidgetRef, String) updateValue;
  final bool numbersOnly;
  final bool formatAsCurrency;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curValue = ref.watch(valueProvider).toString();
    final valueController = useTextEditingController();

    final numberFormat = useMemoized(
        () => NumberFormat.currency(
              locale: Localizations.localeOf(context).toString(),
              symbol: '', // No symbol in the field itself
              decimalDigits: 2,
            ),
        [Localizations.localeOf(context).toString()]);

    final colorAnimation = useAiActionColorAnimation(
      context,
      ref,
      triggerValue: curValue.toString(),
    );

    // Initialize the text field with the correct value
    useEffect(() {
      if (curValue.isNotEmpty) {
        String formattedValue;

        if (formatAsCurrency) {
          try {
            // Parse the value as a number
            final numValue = double.tryParse(curValue) ?? 0.0;
            // Format it as currency
            formattedValue = numberFormat.format(numValue);
          } catch (e) {
            // Fallback to original value if parsing fails
            formattedValue = curValue;
          }
        } else if (numbersOnly) {
          // For non-currency number fields, ensure it's a clean number
          formattedValue = curValue;
        } else {
          // For text fields, use as is
          formattedValue = curValue;
        }

        // Set the text in the controller
        valueController.text = formattedValue;
      }

      return null;
    }, [curValue]);

    // Function to extract raw value from formatted text
    String extractRawValue(String formattedText) {
      if (formatAsCurrency) {
        // Remove all non-digit characters except decimal point
        return formattedText
            .replaceAll(',', '.')
            .replaceAll(RegExp(r'[^\d.]'), '');
      }
      return formattedText;
    }

    return AnimatedBuilder(
      animation: colorAnimation.colorTween,
      builder: (context, child) {
        return KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (KeyEvent event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.tab) {
              // Handle tab key press - update value and allow focus to move
              final rawValue = extractRawValue(valueController.text);
              if (rawValue != curValue) {
                updateValue(ref, rawValue);
              }
            }
          },
          child: TextField(
            minLines: 1,
            maxLines: null,
            controller: valueController,
            enabled: isEditable,
            textInputAction: TextInputAction.next,
            keyboardType: numbersOnly
                ? (formatAsCurrency
                    ? const TextInputType.numberWithOptions(decimal: true)
                    : TextInputType.number)
                : null,
            inputFormatters: numbersOnly
                ? (formatAsCurrency
                    ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
                    : [FilteringTextInputFormatter.digitsOnly])
                : null,
            onEditingComplete: () {
              // Update on editing complete with raw value
              final rawValue = extractRawValue(valueController.text);
              if (rawValue != curValue) {
                updateValue(ref, rawValue);
              }
              FocusScope.of(context).unfocus();
            },
            onTapOutside: (_) {
              // Update on tap outside with raw value
              final rawValue = extractRawValue(valueController.text);
              if (rawValue != curValue) {
                updateValue(ref, rawValue);
              }
              FocusScope.of(context).unfocus();
            },
            textAlign: formatAsCurrency ? TextAlign.end : TextAlign.start,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(0),
              // if we set filled to false, hover color will not work
              fillColor: Colors.transparent,
              enabledBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              border: InputBorder.none,
              isDense: true,
              hoverColor: Theme.of(context).colorScheme.primary.withAlpha(25),
              // Add currency symbol as prefix if needed
              prefixText: (formatAsCurrency && numbersOnly)
                  ? ref.watch(currencyFormatSNP).currencySymbol
                  : null,
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorAnimation.colorTween.value,
                ),
          ),
        );
      },
    );
  }
}

class BaseBudgetAutosuggestionTextField extends HookConsumerWidget {
  const BaseBudgetAutosuggestionTextField({
    super.key,
    required this.isEditable,
    required this.valueProvider,
    required this.updateFieldValue,
    required this.updateBudgetItemRefId,
    required this.fieldToSearch,
  });

  final bool isEditable;
  final ProviderListenable<String> valueProvider;
  final Future Function(WidgetRef, String) updateFieldValue;
  final Future Function(WidgetRef, String) updateBudgetItemRefId;
  final BudgetItemFieldEnum fieldToSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curValue = ref.watch(valueProvider).toString();

    final options =
        ref.watch(curOrgAvailableBudgetItemsStreamProvider).value ?? [];
    // Sort options by code length to improve numeric first matches
    options.sort((a, b) => a.code.length.compareTo(b.code.length));

    return Autocomplete<BudgetItemRefModel>(
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<BudgetItemRefModel>.empty();
        }
        return options.where((option) {
          final valueToCompare = switch (fieldToSearch) {
            BudgetItemFieldEnum.name => option.name,
            BudgetItemFieldEnum.code => option.code,
            _ => '',
          };
          return valueToCompare
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      fieldViewBuilder: (
        context,
        fieldController,
        fieldFocusNode,
        onFieldSubmitted,
      ) {
        return _AutocompleteField(
          curValue: curValue,
          fieldController: fieldController,
          fieldFocusNode: fieldFocusNode,
          isEditable: isEditable,
          updateValue: updateFieldValue,
        );
      },
      onSelected: (option) async {
        FocusScope.of(context).unfocus();
        await updateBudgetItemRefId(ref, option.id);
      },
      displayStringForOption: (option) => switch (fieldToSearch) {
        BudgetItemFieldEnum.name => option.name,
        BudgetItemFieldEnum.code => option.code,
        _ => '',
      },
      optionsViewBuilder: (context, onSelected, options) {
        final currencyFormat = ref.watch(currencyFormatSNP);
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 200,
                maxWidth: 500,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    onTap: () => onSelected(option),
                    leading: SizedBox(
                      width: 60,
                      child: Text(
                        "${option.code}\n${option.source}",
                        maxLines: 4,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    title: Text(option.name, overflow: TextOverflow.ellipsis),
                    subtitle:
                        Text(option.type, overflow: TextOverflow.ellipsis),
                    trailing: Text(
                      currencyFormat.format(option.baseUnitValue),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

// Extracted widget for the field view
class _AutocompleteField extends HookConsumerWidget {
  const _AutocompleteField({
    required this.curValue,
    required this.fieldController,
    required this.fieldFocusNode,
    required this.isEditable,
    required this.updateValue,
  });

  final String curValue;
  final TextEditingController fieldController;
  final FocusNode fieldFocusNode;
  final bool isEditable;
  final Future Function(WidgetRef, String) updateValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorAnimation = useAiActionColorAnimation(
      context,
      ref,
      triggerValue: curValue.toString(),
    );

    useEffect(() {
      if (curValue.isNotEmpty && curValue != fieldController.text) {
        fieldController.text = curValue;
      }
      return null;
    }, [curValue]);

    return AnimatedBuilder(
      animation: colorAnimation.colorTween,
      builder: (context, child) {
        return TextField(
          minLines: 1,
          maxLines: null,
          controller: fieldController,
          focusNode: fieldFocusNode,
          enabled: isEditable,
          textInputAction: TextInputAction.next,
          onEditingComplete: () {
            updateValue(ref, fieldController.text);
          },
          onTapOutside: (_) {
            updateValue(ref, fieldController.text);
            FocusScope.of(context).unfocus(); // Hide the keyboard
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(0),
            fillColor: Colors.transparent,
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            border: InputBorder.none,
            isDense: true,
            hoverColor: Theme.of(context).colorScheme.primary.withAlpha(25),
          ),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorAnimation.colorTween.value,
              ),
        );
      },
    );
  }
}
