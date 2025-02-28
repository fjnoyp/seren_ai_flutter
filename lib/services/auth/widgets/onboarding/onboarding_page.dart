import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/auth/widgets/onboarding/go_to_org_button.dart';
import 'package:seren_ai_flutter/services/data/users/models/invite_model.dart';
import 'package:seren_ai_flutter/services/data/users/providers/cur_user_invites_notifier_provider.dart';

class OnboardingPage extends HookConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get username and create message directly
    final username = ref.watch(curUserProvider).value?.firstName ?? '';
    final message = AppLocalizations.of(context)!.onboardingMessage(username);

    final currentText = useState('');
    final currentCharIndex = useState(0);
    final isTyping = useState(true);
    final showContinueButton = useState(false);

    // Initialize typing animation once
    useEffect(() {
      // Reset state to ensure clean start
      currentText.value = '';
      currentCharIndex.value = 0;
      isTyping.value = true;
      showContinueButton.value = false;

      // Create a properly scoped async function
      Future<void> runAnimation() async {
        try {
          // Type each character with a delay
          for (int i = 0; i < message.length; i++) {
            if (!context.mounted) return;
            await Future.delayed(const Duration(milliseconds: 50));
            if (!context.mounted) return;

            currentText.value = message.substring(0, i + 1);
          }

          if (!context.mounted) return;
          isTyping.value = false;

          // Show continue button after typing is complete
          await Future.delayed(const Duration(seconds: 1));
          if (!context.mounted) return;
          showContinueButton.value = true;
        } catch (e) {
          debugPrint('Animation error: $e');
        }
      }

      // Start the animation
      runAnimation();

      return null;
    }, const []); // Empty dependency array ensures effect runs only once

    final curUserInvites = ref.watch(curUserInvitesNotifierProvider);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentText.value,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AnimatedOpacity(
                    opacity: isTyping.value ? 0 : 1,
                    duration: const Duration(milliseconds: 500),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.ourBuiltInAI,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            SvgPicture.asset('assets/images/AI button.svg',
                                width: 24, height: 24),
                            Text(
                              AppLocalizations.of(context)!.canTeachYouMore,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        Text(
                          AppLocalizations.of(context)!
                              .controlTheApplicationForYou,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          AppLocalizations.of(context)!
                              .andSummarizeAllYourInformation,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  AnimatedOpacity(
                    opacity: (showContinueButton.value) ? 1 : 0,
                    duration: const Duration(milliseconds: 500),
                    child: switch (curUserInvites.length) {
                      0 => FilledButton(
                          onPressed: () =>
                              ref.read(navigationServiceProvider).navigateTo(
                                    AppRoutes.noInvites.name,
                                  ),
                          child: Text(AppLocalizations.of(context)!.letStart),
                        ),
                      1 => GoToOrgButton(curUserInvites.first),
                      _ => const _MultipleInvitesSection(),
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MultipleInvitesSection extends ConsumerWidget {
  const _MultipleInvitesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curUserInvites = ref.watch(curUserInvitesNotifierProvider);
    final curUserInvitesService =
        ref.read(curUserInvitesNotifierProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            AppLocalizations.of(context)!.youHaveMultipleInvitations,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),

        // Pending invites section
        ...curUserInvites
            .where((invite) => invite.status == InviteStatus.pending)
            .map(
              (invite) => ListTile(
                title: Text(invite.orgName),
                subtitle: Text(invite.orgRole.toHumanReadable(context)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () =>
                          curUserInvitesService.declineInvite(invite),
                      tooltip: AppLocalizations.of(context)!.decline,
                    ),
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () =>
                          curUserInvitesService.acceptInvite(invite),
                      tooltip: AppLocalizations.of(context)!.accept,
                    ),
                  ],
                ),
              ),
            ),

        // Accepted orgs section
        if (!curUserInvites
            .any((invite) => invite.status == InviteStatus.pending))
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: curUserInvites
                .where((invite) => invite.status == InviteStatus.accepted)
                .map((org) => GoToOrgButton(org))
                .toList(),
          ),
      ],
    );
  }
}
