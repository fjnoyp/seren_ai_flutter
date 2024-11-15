import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/shifts/widgets/clock_in_out_home_card.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/notes_home_card.dart';
import 'package:seren_ai_flutter/services/data/shifts/widgets/shift_home_card.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_home_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  // We decided to use a time greeting to avoid genre issues when using protuguese.
                  // i.e. Welcome = Bem-vindo (male) / Bem-vinda (female)
                  AppLocalizations.of(context)!.timeGreeting(
                    _getTimePeriod(DateTime.now().hour),
                    'Letty',
                  ),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              children: const [
                TaskHomeCard(),
                NotesCard(),
                ShiftCard(),
                ClockInOutHomeCard(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimePeriod(int hour) {
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    return 'evening';
  }
}
