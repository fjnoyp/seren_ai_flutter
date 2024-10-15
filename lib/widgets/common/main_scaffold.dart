import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/ai_interaction/widgets/user_input_display_widget.dart';
import 'drawer_view.dart';

class MainScaffold extends StatelessWidget {
  final bool enableAiBar = true;

  final String title;
  final Widget body;
  final FloatingActionButton? floatingActionButton;
  final bool showBottomBar;

  const MainScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.showBottomBar = true,
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

      bottomNavigationBar: showBottomBar ? const UserInputDisplayWidget() : null,
    );
  }
}
