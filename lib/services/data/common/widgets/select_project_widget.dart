import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_user_viewable_projects_provider.dart';

class SelectProjectWidget extends ConsumerWidget {
  const SelectProjectWidget({
    super.key,
    required this.curProjectIdValueNotifier,
    required this.showAllValueNotifier,
    required this.showPersonalOption,
  });

  final ValueNotifier<String?> curProjectIdValueNotifier;
  final ValueNotifier<bool> showAllValueNotifier;

  final bool showPersonalOption;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueHandlerWidget(
      value: ref.watch(curUserViewableProjectsProvider),
      loading: () =>
          Center(child: Text(AppLocalizations.of(context)!.loadingProjects)),
      data: (projects) => (projects.isEmpty)
          ? Center(child: Text(AppLocalizations.of(context)!.noProjectsFound))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // "All" filter chip
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      selected: showAllValueNotifier.value,
                      onSelected: (value) {
                        showAllValueNotifier.value = value;
                        if (value) {
                          // When selecting "All", don't change the current project ID
                          // Just remember it for when they switch back
                        } else if (curProjectIdValueNotifier.value == null) {
                          // Make sure we're showing something when unselecting
                          showAllValueNotifier.value = false;
                        }
                      },
                      label: Text(AppLocalizations.of(context)!.all),
                      showCheckmark: false,
                      avatar: const Icon(Icons.notes, size: 16),
                    ),
                  ),
                  if (showPersonalOption)
                    // Personal filter chip
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        selected: !showAllValueNotifier.value &&
                            curProjectIdValueNotifier.value == null,
                        onSelected: (value) {
                          if (value) {
                            curProjectIdValueNotifier.value = null;
                            showAllValueNotifier.value = false;
                          }
                        },
                        label: Text(AppLocalizations.of(context)!.personal),
                        showCheckmark: false,
                      ),
                    ),
                  // Project filter chips
                  ...projects.map(
                    (project) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        selected: !showAllValueNotifier.value &&
                            curProjectIdValueNotifier.value == project.id,
                        onSelected: (value) {
                          if (value) {
                            curProjectIdValueNotifier.value = project.id;
                            showAllValueNotifier.value = false;
                          }
                        },
                        label: Text(project.name),
                        showCheckmark: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
