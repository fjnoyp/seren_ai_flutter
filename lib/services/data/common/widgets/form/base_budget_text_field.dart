import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:seren_ai_flutter/common/currency_provider.dart';
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
    this.initialValue,
  });

  final bool isEditable;
  final ProviderListenable<String> valueProvider;
  final Future Function(WidgetRef, String) updateValue;
  final bool numbersOnly;
  final bool formatAsCurrency;
  final String? initialValue;

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
        return TextField(
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
          },
          onTap: () {
            if (curValue.isEmpty && initialValue != null) {
              updateValue(ref, initialValue!);
            }
          },
          onTapOutside: (_) {
            // Update on tap outside with raw value
            final rawValue = extractRawValue(valueController.text);
            if (rawValue != curValue) {
              updateValue(ref, rawValue);
            }
            FocusScope.of(context).unfocus(); // Hide the keyboard
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
        );
      },
    );
  }
}
