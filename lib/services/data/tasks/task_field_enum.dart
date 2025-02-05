import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// TODO p5: use these enums in the repository updateTask methods instead
enum TaskFieldEnum {
  name,
  status,
  priority,
  assignees;

  String toHumanReadable(BuildContext context) => switch (this) {
        TaskFieldEnum.name => AppLocalizations.of(context)!.name,
        TaskFieldEnum.status => AppLocalizations.of(context)!.status,
        TaskFieldEnum.priority => AppLocalizations.of(context)!.priority,
        TaskFieldEnum.assignees => AppLocalizations.of(context)!.assignees,
      };
}
