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
    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          if (!isWebVersion)
            const Padding(
              padding: EdgeInsets.all(5.0),
              child: GlobalSearchTextField(textAlign: TextAlign.start),
            ),

          // Tab Bar
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: AppLocalizations.of(context)?.recent ?? 'Recent'),
              Tab(text: AppLocalizations.of(context)?.myTasks ?? 'My Tasks'),
              Tab(text: AppLocalizations.of(context)?.notes ?? 'Notes'),
              Tab(text: AppLocalizations.of(context)?.shifts ?? 'Shifts'),
            ],
          ),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                RecentUpdatedItemsScreen(),
                CurUserTasksScreen(),
                NoteListPage(),
                ShiftsPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
