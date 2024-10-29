import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/widgets/home/clock_in_out_card.dart';
import 'package:seren_ai_flutter/widgets/home/notes_home_card.dart';
import 'package:seren_ai_flutter/widgets/home/shift_home_card.dart';
import 'package:seren_ai_flutter/widgets/home/task_home_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Text(
                    AppLocalizations.of(context)!.welcome('Letty'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight * 0.6,
                ),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 9,
                  mainAxisSpacing: 9,
                  children: const [
                    TaskHomeCard(),
                    NotesCard(),
                    ShiftCard(),
                    ClockInOutCard(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
