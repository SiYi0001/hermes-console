import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'shared/theme/hermes_theme.dart';
import 'core/storage/hive_init.dart';
import 'core/services/settings_service.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/connect/connect_screen.dart';
import 'features/console/console_screen.dart';
import 'features/status/status_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/memory/memory_screen.dart';
import 'features/mcp/mcp_screen.dart';
import 'features/automation/automation_screen.dart';
import 'features/logs/logs_screen.dart';
import 'features/gateway/gateway_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/performance/performance_screen.dart';
import 'features/transfer/transfer_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

/// Name of the dedicated Hive box backing [settingsProvider].
const String _appPrefsBox = 'app_prefs';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive storage (real boxes now, not a no-op stub).
  await initStorage();

  // Open the box that backs persistent app settings and inject it so
  // [settingsBoxProvider] resolves inside the widget tree.
  final prefsBox = await Hive.openBox(_appPrefsBox);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: HermesTheme.backgroundBlack,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        settingsBoxProvider.overrideWithValue(prefsBox),
      ],
      child: const HermesConsoleApp(),
    ),
  );
}

Future<void> initStorage() async {
  await HiveInit.initialize();
}

class HermesConsoleApp extends ConsumerWidget {
  const HermesConsoleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Live theme driven by the persisted dark/light preference.
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'HermesConsole',
      debugShowCheckedModeBanner: false,
      theme: HermesTheme.lightTheme,
      darkTheme: HermesTheme.darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}

/// Splash -> first-run onboarding -> main navigation.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    // Navigate after the animation completes.
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final onboardingDone = ref.read(onboardingCompleteProvider);
      if (onboardingDone) {
        _goToMain();
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OnboardingScreen(
              nextScreenBuilder: (_) => const MainNavigation(),
            ),
          ),
        );
      }
    });
  }

  void _goToMain() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainNavigation(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HermesTheme.backgroundBlack,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: HermesTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: HermesTheme.primaryBlue.withValues(alpha: 0.4),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.terminal_rounded,
                  color: Colors.white,
                  size: 64,
                ),
              ),
              const SizedBox(height: 32),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    HermesTheme.primaryBlue,
                    HermesTheme.secondaryPurple,
                  ],
                ).createShader(bounds),
                child: const Text(
                  'HermesConsole',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Secure P2P Agent Control',
                style: TextStyle(
                  fontSize: 14,
                  color: HermesTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  backgroundColor: HermesTheme.surfaceDark,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    HermesTheme.primaryBlue.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Main Navigation Shell
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  // Primary navigation items (bottom nav)
  final List<_NavItem> _primaryItems = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.link, label: 'Connect'),
    _NavItem(icon: Icons.terminal, label: 'Console'),
    _NavItem(icon: Icons.bar_chart, label: 'Status'),
    _NavItem(icon: Icons.settings, label: 'Settings'),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          DashboardScreen(),
          ConnectScreen(),
          ConsoleScreen(),
          StatusScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_primaryItems.length, (index) {
              final item = _primaryItems[index];
              final isSelected = _currentIndex == index;

              return GestureDetector(
                onTap: () => _onNavTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? HermesTheme.primaryBlue.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color: isSelected
                            ? HermesTheme.primaryBlue
                            : HermesTheme.textSecondary,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? HermesTheme.primaryBlue
                              : HermesTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: HermesTheme.surfaceDark,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: HermesTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.terminal_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HermesConsole',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'v2.4.0',
                          style: TextStyle(
                            fontSize: 13,
                            color: HermesTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: HermesTheme.surfaceOverlay),

            // Drawer Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.psychology,
                    label: 'Memory & Skills',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MemoryScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.extension,
                    label: 'MCP Tools',
                    badge: '4',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const McpScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.schedule,
                    label: 'Automation',
                    badge: '12',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AutomationScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.article,
                    label: 'Logs & Audit',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LogsScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.hub,
                    label: 'Gateway',
                    badge: '5',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GatewayScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.notifications,
                    label: 'Notifications',
                    badge: '5',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationsScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.file_copy,
                    label: 'File Transfer',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TransferScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.speed,
                    label: 'Performance',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PerformanceScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.person,
                    label: 'Profile',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    },
                  ),
                  const Divider(color: HermesTheme.surfaceOverlay, height: 32),
                  _DrawerItem(
                    icon: Icons.help_outline,
                    label: 'Help & Documentation',
                    onTap: () {},
                  ),
                  _DrawerItem(
                    icon: Icons.info_outline,
                    label: 'About',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // Connection Status
            Container(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: HermesTheme.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: HermesTheme.successGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 8,
                      height: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: HermesTheme.successGreen,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connected',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: HermesTheme.successGreen,
                            ),
                          ),
                          Text(
                            'hermes-agent-001',
                            style: TextStyle(
                              fontSize: 11,
                              color: HermesTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: HermesTheme.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem({required this.icon, required this.label});
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: HermesTheme.textSecondary),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: HermesTheme.primaryBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  fontSize: 11,
                  color: HermesTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : const Icon(
              Icons.chevron_right,
              color: HermesTheme.textSecondary,
            ),
      onTap: onTap,
    );
  }
}
