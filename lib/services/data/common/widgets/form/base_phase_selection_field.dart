import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/selection_field.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/tasks_by_project_stream_provider.dart';

class BasePhaseSelectionField extends ConsumerWidget {
  final bool enabled;
  final ProviderListenable<String?> phaseIdProvider;
  final ProviderListenable<String?> projectIdProvider;
  final Function(WidgetRef, String?) updatePhase;

  const BasePhaseSelectionField({
    super.key,
    required this.enabled,
    required this.phaseIdProvider,
    required this.projectIdProvider,
    required this.updatePhase,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emptyValueString =
        AppLocalizations.of(context)?.choosePhase ?? 'Choose Phase';

    final projectId = ref.watch(projectIdProvider);
    if (projectId == null) {
      return const SizedBox.shrink();
    }

    // Improve performance by using a selector provider
    // avoiding unnecessary rebuilds
    final selectablePhases = ref
        .watch(parentTasksByProjectStreamProvider(projectId).select((phases) {
      return phases.hasValue
          ? phases.value!
              .map((phase) => (id: phase.id, name: phase.name))
              .toList()
          : <({String id, String name})>[];
    }));

    // Handle loading state
    if (selectablePhases.isEmpty) {
      return const Center(child: LinearProgressIndicator());
    }

    final curPhaseId = ref.watch(phaseIdProvider);
    final curPhaseName = curPhaseId != null
        ? ref.watch(taskByIdStreamProvider(curPhaseId)
            .select((task) => task.value?.name))
        : null;

    return enabled
        ? AnimatedModalSelectionField<({String id, String name})>(
            labelWidget: Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context)?.phase ?? 'Phase',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (curPhaseId != null && curPhaseName != null)
                    TextButton(
                      onPressed: () =>
                          ref.read(taskNavigationServiceProvider).openTask(
                                initialTaskId: curPhaseId,
                                // replace to avoid duplicated task pages/dialogs
                                withReplacement: true,
                              ),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onSurface,
                      ),
                      child: Text(curPhaseName),
                    ),
                ],
              ),
            ),
            valueToString: (phase) => phase?.name ?? emptyValueString,
            valueToWidget: (phase) => Tooltip(
              message: emptyValueString,
              child: const Icon(Icons.arrow_drop_down),
            ),
            enabled: enabled,
            value: curPhaseId != null
                ? selectablePhases.firstWhere((phase) => phase.id == curPhaseId)
                : null,
            options: selectablePhases,
            onValueChanged: (ref, phase) => updatePhase(ref, phase?.id),
            isValueRequired: false,
          )
        : Text(curPhaseName ?? emptyValueString);
  }
}
