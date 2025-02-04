import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/common/build_info.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BuildInfoSection extends StatelessWidget {
  const BuildInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.info_outline),
      title: Text(
        'v${BuildInfo.version} (${BuildInfo.commitHash}) - Warning last commit is NOT shown',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${BuildInfo.lastCommitAuthor}: ${BuildInfo.recentCommits[0]["message"]}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => showDialog(
        context: context,
        builder: (context) => _BuildInfoDialog(),
      ),
    );
  }
}

class _BuildInfoDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.about),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Version', BuildInfo.version),
            _buildSection('Build Date', BuildInfo.buildDate),
            const Divider(),
            _buildSection('Branch', BuildInfo.branch),
            _buildSection('Last Tag', BuildInfo.lastTag),
            _buildSection('Total Commits', BuildInfo.totalCommits),
            const Text('Warning: Last commit is NOT shown'),
            const Divider(),
            const Text('Recent Commits',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...BuildInfo.recentCommits.map((commit) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${commit["message"]}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'by ${commit["author"]} (${commit["relativeDate"]})',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        ),
      ],
    );
  }

  Widget _buildSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
