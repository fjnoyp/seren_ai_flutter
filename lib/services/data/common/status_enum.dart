import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum StatusEnum {
  cancelled,
  open,
  inProgress,
  finished,
  archived;

  String toHumanReadable(BuildContext context) => switch (this) {
        StatusEnum.cancelled => AppLocalizations.of(context)!.cancelled,
        StatusEnum.open => AppLocalizations.of(context)!.open,
        StatusEnum.inProgress => AppLocalizations.of(context)!.inProgress,
        StatusEnum.finished => AppLocalizations.of(context)!.finished,
        StatusEnum.archived => AppLocalizations.of(context)!.archived,
      };

  static StatusEnum tryParse(String? value) {
    if (value == null) return StatusEnum.open;
    try {
      // exception case for 'inprogress'
      if (value.toLowerCase() == 'inprogress') return StatusEnum.inProgress;

      return StatusEnum.values.byName(value.toLowerCase());
    } catch (_) {
      return StatusEnum.open;
    }
  }
}
