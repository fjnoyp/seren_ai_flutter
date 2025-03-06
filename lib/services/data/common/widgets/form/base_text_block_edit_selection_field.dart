import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
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

              // Use a custom widget that shows formatted text
              return FormattedTextInput(
                controller: controller,
                hintText:
                    hintText ?? AppLocalizations.of(context)!.enterTextHere,
                labelWidget: labelWidget,
                onSubmitted: (value) async {
                  await updateDescription(ref, value);
                },
                onTapOutside: () async {
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

class FormattedTextInput extends HookWidget {
  final TextEditingController controller;
  final String? hintText;
  final Widget? labelWidget;
  final Function(String)? onSubmitted;
  final Function()? onTapOutside;

  const FormattedTextInput({
    super.key,
    required this.controller,
    this.hintText,
    this.labelWidget,
    this.onSubmitted,
    this.onTapOutside,
  });

  @override
  Widget build(BuildContext context) {
    final focusNode = useFocusNode();
    final isFocused = useState(false);

    // Force rebuild when text changes
    useValueListenable(controller);

    useEffect(() {
      void onFocusChange() {
        isFocused.value = focusNode.hasFocus;
        if (!focusNode.hasFocus && onTapOutside != null) {
          onTapOutside!();
        }
      }

      focusNode.addListener(onFocusChange);
      return () => focusNode.removeListener(onFocusChange);
    }, [focusNode]);

    // Get the current theme text style for proper text appearance
    final textStyle = Theme.of(context).textTheme.bodyMedium!;
    final hintStyle = textStyle.copyWith(color: Theme.of(context).hintColor);

    return GestureDetector(
      onTap: () {
        focusNode.requestFocus();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (labelWidget != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                child: labelWidget!,
              ),
            Expanded(
              child: Stack(
                children: [
                  // Invisible TextField for handling input
                  TextField(
                    controller: controller,
                    focusNode: focusNode,
                    minLines: 1,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: hintText,
                      fillColor: Colors.transparent,
                      filled: true,
                      enabledBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      border: InputBorder.none,
                      hoverColor:
                          Theme.of(context).colorScheme.primary.withAlpha(25),
                      // Add padding to match the RichText padding
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    style: textStyle.copyWith(
                      // Make the text invisible but keep the cursor visible
                      color: Colors.transparent,
                      // Match the height of the RichText for proper cursor positioning
                      height: 1.5,
                    ),
                    onSubmitted: onSubmitted,
                    cursorColor: Theme.of(context).colorScheme.primary,
                  ),

                  // Formatted text display
                  if (controller.text.isNotEmpty)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: RichText(
                            text: _buildFormattedTextSpan(
                              controller.text,
                              context,
                              textStyle,
                              showMarkers: isFocused.value,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            hintText ?? '',
                            style: hintStyle,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextSpan _buildFormattedTextSpan(
      String text, BuildContext context, TextStyle baseStyle,
      {bool showMarkers = true}) {
    final List<TextSpan> spans = [];
    final RegExp boldPattern = RegExp(r'\*(.*?)\*');
    final RegExp italicPattern = RegExp(r'_(.*?)_');
    final RegExp strikethroughPattern = RegExp(r'~(.*?)~');
    final RegExp codePattern = RegExp(r'```(.*?)```', dotAll: true);

    int currentPosition = 0;

    // Find all formatting patterns
    final allMatches = [
      ...boldPattern.allMatches(text).map((m) => _FormatMatch(m, 'bold')),
      ...italicPattern.allMatches(text).map((m) => _FormatMatch(m, 'italic')),
      ...strikethroughPattern
          .allMatches(text)
          .map((m) => _FormatMatch(m, 'strikethrough')),
      ...codePattern.allMatches(text).map((m) => _FormatMatch(m, 'code')),
    ]..sort((a, b) => a.match.start.compareTo(b.match.start));

    // Process matches in order
    for (final formatMatch in allMatches) {
      final match = formatMatch.match;

      // Add plain text before this match
      if (match.start > currentPosition) {
        spans.add(TextSpan(
          text: text.substring(currentPosition, match.start),
          style: baseStyle,
        ));
      }

      // Extract the content and the markers
      final String content = match.group(1) ?? '';
      String prefix, suffix;

      switch (formatMatch.type) {
        case 'bold':
          prefix = '*';
          suffix = '*';
          break;
        case 'italic':
          prefix = '_';
          suffix = '_';
          break;
        case 'strikethrough':
          prefix = '~';
          suffix = '~';
          break;
        case 'code':
          prefix = '```';
          suffix = '```';
          break;
        default:
          prefix = '';
          suffix = '';
      }

      // Add the prefix with outline color if showing markers
      if (showMarkers) {
        spans.add(TextSpan(
          text: prefix,
          style: baseStyle.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ));
      }

      // Add the content with formatted style
      TextStyle formattedStyle;
      switch (formatMatch.type) {
        case 'bold':
          formattedStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);
          break;
        case 'italic':
          formattedStyle = baseStyle.copyWith(fontStyle: FontStyle.italic);
          break;
        case 'strikethrough':
          formattedStyle =
              baseStyle.copyWith(decoration: TextDecoration.lineThrough);
          break;
        case 'code':
          // Use Google Fonts for monospace only when not focused
          if (!showMarkers) {
            formattedStyle = GoogleFonts.robotoMono(
              textStyle: baseStyle,
              color: Theme.of(context).colorScheme.onInverseSurface,
              backgroundColor: Theme.of(context).colorScheme.inverseSurface,
            );
          } else {
            // When focused, use regular font with background color
            formattedStyle = baseStyle.copyWith(
              backgroundColor: Theme.of(context).colorScheme.inverseSurface,
              color: Theme.of(context).colorScheme.onInverseSurface,
            );
          }
          break;
        default:
          formattedStyle = baseStyle;
      }

      spans.add(TextSpan(
        text: content,
        style: formattedStyle,
      ));

      // Add the suffix with outline color if showing markers
      if (showMarkers) {
        spans.add(TextSpan(
          text: suffix,
          style: baseStyle.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ));
      }

      currentPosition = match.end;
    }

    // Add any remaining text
    if (currentPosition < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentPosition),
        style: baseStyle,
      ));
    }

    return TextSpan(children: spans);
  }
}

class _FormatMatch {
  final RegExpMatch match;
  final String type;

  _FormatMatch(this.match, this.type);
}
