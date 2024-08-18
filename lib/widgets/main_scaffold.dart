import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seren_ai_flutter/services/ai_orchestrator_provider.dart';
import 'package:seren_ai_flutter/services/speech_to_text/widgets/speech_state_control_button_widget.dart';
import 'package:seren_ai_flutter/services/speech_to_text/widgets/speech_transcribed_widget.dart';
import 'drawer_view.dart';

class MainScaffold extends StatelessWidget {
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
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: body,
      ),
      //floatingActionButton: floatingActionButton,
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          return FloatingActionButton(
            onPressed: () {
              ref.read(aiOrchestratorProvider).testMove(context);              
            },       
            child: Icon(Icons.pets)        
          );
        },
      ),
      // bottomSheet
      bottomNavigationBar: Consumer(
        builder: (context, ref, child) {
          final isTextFieldVisible = ref.watch(textFieldVisibilityProvider);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isTextFieldVisible ? 200 : 150,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              border: Border.all(color: Colors.grey),
            ),
            child: Column(
              children: [
                if (isTextFieldVisible)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: VisibleTextFieldWidget(),
                  ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 1),
                      const Expanded(
                        flex: 1,
                        child: SpeechStateControlButtonWidget(),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: Icon(
                              isTextFieldVisible ? Icons.cancel : Icons.create),
                          onPressed: () {
                            ref.read(textFieldVisibilityProvider.notifier).state =
                                !isTextFieldVisible;
                          },
                        ),
                      ),
                      // TODO p1: readd - SpeechTranscribedWidget(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

final textFieldVisibilityProvider = StateProvider<bool>((ref) => false);

final TextEditingController textEditingController = TextEditingController();


class VisibleTextFieldWidget extends ConsumerWidget {
  const VisibleTextFieldWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTextFieldVisible = ref.watch(textFieldVisibilityProvider);
    return Visibility(
      visible: isTextFieldVisible,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 100,
        ),
        child: SingleChildScrollView(
          child: TextField(
            controller: textEditingController,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'Enter something',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (String value) {
              // Hide the TextField after input is submitted
              ref.read(textFieldVisibilityProvider.notifier).state = false;

              // Submit
              //ref.read(langchainNotifierProvider.notifier).askConversation(textEditingController.text);

              textEditingController.clear();
            },
          ),
        ),
      ),
    );
  }
}
