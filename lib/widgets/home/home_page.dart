import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/widgets/home/base_home_card.dart';
import 'package:seren_ai_flutter/widgets/home/clock_in_out_card.dart';
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
                    'Welcome,\nLetty!',
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

Widget NoteCardItem(
    {required String title,
    required String subtitle,
    required BuildContext context}) {
  return Card(
    color: Theme.of(context).colorScheme.primary,
    child: Padding(
      padding: const EdgeInsets.all(8.0), // Added inner padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ),
  );
}

class NotesCard extends StatelessWidget {
  const NotesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseHomeCard(
      title: "Notes",
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: NoteCardItem(
                title: "Meeting Note",
                subtitle: "Meeting Notes",
                context: context),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: NoteCardItem(
                title: "Site Notes",
                subtitle: "New roof notations",
                context: context),
          ),
        ],
      ),
    );
  }
}
