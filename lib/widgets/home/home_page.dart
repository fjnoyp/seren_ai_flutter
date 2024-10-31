import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/widgets/home/clock_in_out_card.dart';
import 'package:seren_ai_flutter/widgets/home/notes_home_card.dart';
import 'package:seren_ai_flutter/widgets/home/shift_home_card.dart';
import 'package:seren_ai_flutter/widgets/home/task_home_card.dart';

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
                  'Welcome,\nLetty!',
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
                ClockInOutCard(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
