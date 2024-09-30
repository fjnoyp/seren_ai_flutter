import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:seren_ai_flutter/widgets/home/base_home_card.dart';
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
              Container(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight * 0.6,
                  ),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 9,
                    mainAxisSpacing: 9,
                    children: [
                      TaskHomeCard(),
                      NotesCard(),
                      ShiftCard(),
                      ClockInOutCard(),
                    ],
                  ),
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

class ShiftCard extends StatelessWidget {
  const ShiftCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseHomeCard(
      title: "Today's Shift",
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: Card(
          color: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // Added to make the column take up only the necessary space
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Monday, 30 Jun",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "9:00 to 18:00",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ClockInOutCard extends StatelessWidget {
  const ClockInOutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseHomeCard(
      title: "Clock in/out",
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: Card(
          color: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),       
                    SizedBox(width: 8),
                    TextButton(
                      onPressed: () {},
                      child: Text("Start Shift"),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                Text(
                  "Last logged 9:01",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
