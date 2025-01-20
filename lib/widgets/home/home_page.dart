import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/shifts/widgets/clock_in_out_home_card.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/notes_home_card.dart';
import 'package:seren_ai_flutter/services/data/shifts/widgets/shift_home_card.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_home_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              // Should we use this widget here, since an unauthenticated user will never see this page?
              child: AsyncValueHandlerWidget(
                value: ref.watch(curUserProvider),
                data: (user) => Text(
                  // We decided to use a time greeting to avoid genre issues when using protuguese.
                  // i.e. Welcome = Bem-vindo (male) / Bem-vinda (female)
                  AppLocalizations.of(context)!.timeGreeting(
                    _getTimePeriod(DateTime.now().hour),
                    user!.firstName,
                  ),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: (MediaQuery.of(context).size.width > 600)
                      ? constraints.maxWidth / (constraints.maxHeight / 2)
                      : 1.0, // Default aspect ratio for non-web
                  children: const [
                    TaskHomeCard(),
                    NoteHomeCard(),
                    ShiftCard(),
                    ClockInOutHomeCard(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getTimePeriod(int hour) {
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    return 'evening';
  }
}
