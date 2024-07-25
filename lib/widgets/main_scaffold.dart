import 'package:flutter/material.dart';
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
      floatingActionButton: floatingActionButton,
    );
  }
}
