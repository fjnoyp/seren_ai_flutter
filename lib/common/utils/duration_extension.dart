import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension DurationFormatting on Duration {
  String formatDuration(BuildContext context) {
    String twoDigits(int n) => n.toString();
    String hours = twoDigits(inHours);
    String minutes = twoDigits(inMinutes.remainder(60));

    if (hours == "0" && minutes == "0") {
      return AppLocalizations.of(context)!.zeroHours;
    }
    if (minutes == "0") {
      return AppLocalizations.of(context)!.durationHoursOnly(int.parse(hours));
    }
    return AppLocalizations.of(context)!.durationFormat(hours, minutes);
  }
}
