import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/settings_service.dart';
import '../../shared/theme/hermes_theme.dart';

/// First-run onboarding flow.
///
/// Shown only when [AppSettings.onboardingComplete] is false. On completion it
/// persists the flag so the flow never appears again. Pure UI + one persisted
/// write; no mock data.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.nextScreenBuilder});

  /// Builds the screen shown after onboarding completes. The navigation is
  /// performed from this widget's own context (not a captured parent context)
  /// to avoid using a deactivated BuildContext after [pushReplacement].
  final Widget Function(BuildContext) nextScreenBuilder;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  static const List<_OnboardPage> _pages = [
    _OnboardPage(
      icon: Icons.hub_outlined,
      title: 'Peer-to-Peer, No Middleman',
      body:
          'HermesConsole connects your devices directly over WebRTC '
          'DataChannels. Your data never touches a central server.',
      accent: Color(0xFF4F8CFF),
    ),
    _OnboardPage(
      icon: Icons.lock_outline,
      title: 'End-to-End Encrypted',
      body:
          'Every message is sealed with AES-256-GCM and keys exchanged via '
          'Curve25519. Only you and your peer can read them.',
      accent: Color(0xFF34D399),
    ),
    _OnboardPage(
      icon: Icons.bolt_outlined,
      title: 'Fast & Lightweight',
      body:
          'Adaptive compression, batched UI updates, and a memory-efficient '
          'console keep everything snappy — even on older devices.',
      accent: Color(0xFFF59E0B),
    ),
    _OnboardPage(
      icon: Icons.dashboard_customize_outlined,
      title: 'Everything in One Console',
      body:
          'Dashboard, terminal, file transfer, automation, MCP tools, and '
          'long-term memory — all in a single unified app.',
      accent: Color(0xFFA78BFA),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _page == _pages.length - 1;

  Future<void> _finish() async {
    await ref.read(settingsProvider.notifier).completeOnboarding();
    if (mounted) {
      unawaited(Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: widget.nextScreenBuilder),
      ));
    }
  }

  void _next() {
    if (_isLast) {
      unawaited(_finish());
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => _OnboardPageView(page: _pages[i]),
              ),
            ),
            _PageIndicator(count: _pages.length, active: _page),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _next,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: _pages[_page].accent,
                      ),
                      child: Text(
                        _isLast ? 'Get Started' : 'Next',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage {
  const _OnboardPage({
    required this.icon,
    required this.title,
    required this.body,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color accent;
}

class _OnboardPageView extends StatelessWidget {
  const _OnboardPageView({required this.page});

  final _OnboardPage page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  page.accent.withValues(alpha: 0.30),
                  page.accent.withValues(alpha: 0.04),
                ],
              ),
            ),
            child: Icon(page.icon, size: 64, color: page.accent),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? HermesTheme.primaryBlue
                : HermesTheme.primaryBlue.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
