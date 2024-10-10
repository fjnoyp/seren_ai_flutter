import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seren_ai_flutter/services/ai_interaction/ai_api_provider.dart';
import 'package:seren_ai_flutter/services/speech_to_text/widgets/speech_state_control_button_widget.dart';
import 'package:seren_ai_flutter/services/speech_to_text/widgets/speech_transcribed_widget.dart';
import 'package:seren_ai_flutter/widgets/common/drawer_view.dart';

class MainScaffold extends StatelessWidget {
  final bool enableAiBar = true;

  final String title;
  final Widget body;
  final FloatingActionButton? floatingActionButton;

  const MainScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return Row(
              children: [
                IconButton(
                  icon: Icon(Icons.menu, color: theme.iconTheme.color),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
                // TODO p2: user can pop out to nothing on the starting page ... back button is in a weird location. we should only conditionally show back button
                if (Navigator.of(context).canPop())
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
              ],
            );
          },
        ),
        leadingWidth: Navigator.of(context).canPop()
            ? 96
            : 48, // Adjust width based on whether back button is shown

        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: theme.appBarTheme.titleTextStyle,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const DrawerView(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(0),
            child: body,
          ),
          
        ],
      ),

      /*
      floatingActionButton: enableAiBar ? Consumer(
        builder: (context, ref, child) {
          return FloatingActionButton(
            onPressed: () {
              ref.read(aiOrchestratorProvider).testMove(context);
            },
            child: Icon(Icons.pets),
          );
        },
      ) : null,
      */

      bottomNavigationBar: enableAiBar
          ? Consumer(
              builder: (context, ref, child) {
                final isTextFieldVisible =
                    ref.watch(textFieldVisibilityProvider);
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const UserInputTextDisplayWidget(),
                      const SpeechTranscribedWidget(),
                      const SpeechStateControlButtonWidget(),
                      IconButton(
                        icon: Icon(
                            isTextFieldVisible ? Icons.cancel : Icons.keyboard),
                        onPressed: () {
                          ref.read(textFieldVisibilityProvider.notifier).state =
                              !isTextFieldVisible;
                        },
                      ),
                      // You can add more widgets here if needed
                    ],
                  ),
                );
              },
            )
          : null,
    );
  }
}

final textFieldVisibilityProvider = StateProvider<bool>((ref) => false);
final TextEditingController textEditingController = TextEditingController();

class UserInputTextDisplayWidget extends ConsumerWidget {
  const UserInputTextDisplayWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTextFieldVisible = ref.watch(textFieldVisibilityProvider);
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Visibility(
      visible: isTextFieldVisible,
      child: Positioned(
        bottom: viewInsets.bottom,
        left: 0,
        right: 0,
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.check_box_outlined, size: 20),
                    onPressed: () {
                      ref.read(textFieldVisibilityProvider.notifier).state =
                          false;
                      ref
                          .read(aiApiProvider)
                          .sendMessageToAi(message: textEditingController.text);
                      textEditingController.clear();
                    },
                    color: Colors.green,
                  ),
                  IconButton(
                    icon: Icon(Icons.close_outlined, size: 20),
                    onPressed: () {
                      ref.read(textFieldVisibilityProvider.notifier).state =
                          false;
                      textEditingController.clear();
                    },
                    color: Colors.red,
                  ),
                ],
              ),
              TextField(
                controller: textEditingController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Enter something',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
