import 'package:collection/collection.dart';
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
    final phasesResult = ref
        .watch(parentTasksByProjectStreamProvider(projectId).select((phases) {
      return (
        isLoading: phases.isLoading,
        phases: phases.hasValue
            ? phases.value!
                .map((phase) => (id: phase.id, name: phase.name))
                .toList()
            : <({String id, String name})>[]
      );
    }));

    // Handle loading state
    if (phasesResult.isLoading) {
      return const Center(child: LinearProgressIndicator());
    }

    final selectablePhases = phasesResult.phases;

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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (curPhaseId != null &&
                      curPhaseName != null &&
                      selectablePhases.isNotEmpty) // prevent previously (wrongly) set phases with empty state
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
            valueToString: (phase) => selectablePhases.isEmpty
                ? AppLocalizations.of(context)
                        ?.thisProjectCurrentlyHasNoPhases ??
                    'This project currently has no phases'
                : phase?.name ?? emptyValueString,
            valueToWidget: (phase) => Tooltip(
              message: emptyValueString,
              child: const Icon(Icons.arrow_drop_down),
            ),
            enabled: enabled,
            value: curPhaseId != null
                ? selectablePhases
                    .firstWhereOrNull((phase) => phase.id == curPhaseId)
                : null,
            options: selectablePhases,
            onValueChanged: (ref, phase) => updatePhase(ref, phase?.id),
            isValueRequired: false,
            expandHorizontally: false,
          )
        : Text(curPhaseName ?? emptyValueString);
  }
}
