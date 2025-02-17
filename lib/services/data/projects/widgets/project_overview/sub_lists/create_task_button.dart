import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateTaskButton extends ConsumerWidget {
  final String? initialProjectId;
  final StatusEnum? initialStatus;

  const CreateTaskButton({
    super.key,
    this.initialProjectId,
    this.initialStatus,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(20),
          alignment: Alignment.centerLeft,
          overlayColor: Colors.transparent,
        ),
        onPressed: () async {
          await ref.read(taskNavigationServiceProvider).openNewTask(
                initialProjectId: initialProjectId,
                initialStatus: initialStatus,
              );
        },
        child: Text(
          AppLocalizations.of(context)!.createNewTask,
        ),
      ),
    );
  }
}
