import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/notes_list_page.dart';
import 'package:seren_ai_flutter/services/data/shifts/widgets/shifts_page.dart';
import 'package:seren_ai_flutter/widgets/search/global_search_text_field.dart';
import 'package:seren_ai_flutter/widgets/home/screens/cur_user_tasks_screen.dart';
import 'package:seren_ai_flutter/widgets/home/screens/recent_updated_items_screen.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (
        label: AppLocalizations.of(context)?.recent ?? 'Recent',
        icon: Icons.history_outlined,
        body: const RecentUpdatedItemsScreen()
      ),
      (
        label: AppLocalizations.of(context)?.myTasks ?? 'My Tasks',
        icon: Icons.task_outlined,
        body: const CurUserTasksScreen()
      ),
      (
        label: AppLocalizations.of(context)?.notes ?? 'Notes',
        icon: Icons.note_outlined,
        body: const NoteListPage()
      ),
      (
        label: AppLocalizations.of(context)?.shifts ?? 'Shifts',
        icon: Icons.punch_clock_outlined,
        body: const ShiftsPage()
      ),
    ];

    // Calculate available width for tabs
    // final screenWidth = MediaQuery.of(context).size.width;

    // Check if screen is too narrow for full tab labels
    // 70 is the average width of a tab label
    // 32 is the default horizontal padding
    // final isNarrowScreen = screenWidth - 32 < (70 + 32) * tabs.length;

    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          if (!isWebVersion)
            const Padding(
              padding: EdgeInsets.all(5.0),
              child: GlobalSearchTextField(textAlign: TextAlign.start),
            ),

          // Tab Bar - conditionally show text or icon based on screen width
          TabBar(
            controller: _tabController,
            tabs: tabs
                .map((tab) => Tab(text: tab.label, icon: Icon(tab.icon)))
                .toList(),
          ),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: tabs.map((tab) => tab.body).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
