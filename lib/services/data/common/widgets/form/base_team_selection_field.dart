import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/selection_field.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';

class BaseTeamSelectionField extends ConsumerWidget {
  final bool enabled;
  final ProviderListenable<TeamModel?> teamProvider;
  final ProviderListenable<List<TeamModel>?> selectableTeamsProvider;
  final Function(WidgetRef, TeamModel?) updateTeam;

  const BaseTeamSelectionField({
    super.key,
    required this.enabled,
    required this.teamProvider,
    required this.selectableTeamsProvider,
    required this.updateTeam,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curTaskTeam = ref.watch(teamProvider);
    final selectableTeams = ref.watch(selectableTeamsProvider);

    return AnimatedModalSelectionField<TeamModel>(
      labelWidget: SizedBox(
        width: 60,
        child: Text(
          AppLocalizations.of(context)!.team,
          style: const TextStyle(fontWeight: FontWeight.bold)
        ),
      ),
      validator: (team) => team == null 
          ? AppLocalizations.of(context)!.teamIsRequired 
          : null,
      valueToString: (team) => team?.name ?? AppLocalizations.of(context)!.selectATeam,
      enabled: enabled,
      value: curTaskTeam,
      options: selectableTeams ?? [],
      onValueChanged: (ref, team) {
        updateTeam(ref, team);
      },
    );
  }
}
