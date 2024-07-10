import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                      TaskCard(),
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

class OuterCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final String title;

  const OuterCard(
      {super.key,
      required this.child,
      required this.color,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      margin: EdgeInsets.all(2),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,                
              ),
            ],
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

Widget TaskCardItem({required String title, required BuildContext context}) {
  return Card(
    color: Theme.of(context).colorScheme.primary,
    child: Row(
      children: [
        Checkbox(
          value: false,
          onChanged: (newValue) {},
        ),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
            maxLines: null,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    ),
  );
}

class TaskCard extends StatelessWidget {
  const TaskCard({super.key});

  @override
  Widget build(BuildContext context) {
    return OuterCard(
      color: Theme.of(context).colorScheme.primaryContainer,
      title: "Today's Tasks",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            fit:
                FlexFit.tight, // Ensures the child takes up the available space
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // Changed from ListView to Column
              children: [
                Flexible(
                    fit: FlexFit.loose,
                    child: TaskCardItem(
                        title: "Inspect Foundation Work", context: context)),
                Flexible(
                    fit: FlexFit.loose,
                    child: TaskCardItem(
                        title: "Address Safety Issues", context: context)),
                Flexible(
                  fit: FlexFit.loose,
                  child: Card(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        height: 30, // Set max height to 10
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.primary),
                          borderRadius: BorderRadius.circular(
                              12), // Increased the border radius for more rounded edges
                        ),
                        child: Center(
                          child: Text(
                            "See All",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
    return OuterCard(
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
    return OuterCard(
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
    return OuterCard(
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
