import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/auth/widgets/onboarding/accept_org_invite_button.dart';
import 'package:seren_ai_flutter/services/data/users/providers/cur_user_invites_notifier_provider.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  String _message = '';

  String _currentText = '';
  int _currentCharIndex = 0;
  bool _isTyping = true;
  bool _showContinueButton = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only initialize the message and start typing once
    if (_message.isEmpty) {
      final username = ref.read(curUserProvider).value?.firstName ?? '';
      _message = AppLocalizations.of(context)!.onboardingMessage(username);
      _startTypingAnimation();
    }
  }

  void _startTypingAnimation() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;

      if (_currentCharIndex < _message.length) {
        setState(() {
          _currentText = _message.substring(0, _currentCharIndex + 1);
          _currentCharIndex++;
        });
        _startTypingAnimation();
      } else {
        setState(() {
          _isTyping = false;
        });

        // Show continue button 1 second after typing is complete
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          setState(() {
            _showContinueButton = true;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final curUserInvites = ref.watch(curUserInvitesNotifierProvider);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentText,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                AnimatedOpacity(
                  opacity: _isTyping ? 0 : 1,
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
                  opacity: (_showContinueButton) ? 1 : 0,
                  duration: const Duration(milliseconds: 500),
                  child: curUserInvites.length == 1
                      ? AcceptInviteButton(curUserInvites.first)
                      : FilledButton(
                          onPressed: () {
                            ref.read(navigationServiceProvider).navigateTo(
                                  AppRoutes.noInvites.name,
                                );
                          },
                          child: Text(AppLocalizations.of(context)!.letStart)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
