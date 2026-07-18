import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme/hermes_theme.dart';
import '../../shared/widgets/optimized_widgets.dart';
import '../../core/performance/performance_optimizations.dart';

/// Optimized Dashboard Screen with minimal rebuilds
class OptimizedDashboardScreen extends ConsumerStatefulWidget {
  const OptimizedDashboardScreen({super.key});

  @override
  ConsumerState<OptimizedDashboardScreen> createState() => _OptimizedDashboardScreenState();
}

class _OptimizedDashboardScreenState extends ConsumerState<OptimizedDashboardScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: HermesTheme.backgroundBlack,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: HermesTheme.backgroundBlack,
              title: const _AppBarTitle(),
              actions: const [
                _NotificationBadge(),
                SizedBox(width: 8),
              ],
            ),

            // Connection Status
            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ConnectionStatusCard(),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Quick Actions
            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _QuickActionsGrid(),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Recent Sessions Header
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _SectionHeader(title: 'Recent Sessions'),
              ),
            ),

            // Sessions List
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => RepaintBoundary(
                    child: _SessionCard(index: index),
                  ),
                  childCount: 3,
                ),
              ),
            ),

            // System Stats
            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SystemStatsCard(),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _AppBarTitle extends ConsumerWidget {
  const _AppBarTitle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Text(
      'HermesConsole',
      style: CachedTextStyle.headline2,
    );
  }
}

class _NotificationBadge extends ConsumerWidget {
  const _NotificationBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountProvider);

    return Stack(
      children: [
        const OptimizedIconButton(
          icon: Icons.notifications_outlined,
          color: Colors.white,
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: HermesTheme.errorRed,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class _ConnectionStatusCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectionStatusProvider);
    final latency = ref.watch(connectionLatencyProvider);

    final isConnected = status == ConnectionStatus.connected;
    final isConnecting = status == ConnectionStatus.connecting;

    return GlassCard(
      child: Row(
        children: [
          // Status Indicator
          AnimatedStatusIndicator(
            isActive: isConnected,
            activeColor: isConnecting ? HermesTheme.warningAmber : HermesTheme.successGreen,
            size: 14,
          ),
          const SizedBox(width: 16),

          // Status Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected
                      ? 'Connected'
                      : isConnecting
                          ? 'Connecting...'
                          : 'Disconnected',
                  style: CachedTextStyle.headline3,
                ),
                if (isConnected)
                  Text(
                    'Latency: ${latency}ms',
                    style: CachedTextStyle.caption,
                  ),
              ],
            ),
          ),

          // Action Button
          if (!isConnected && !isConnecting)
            _QuickActionButton(
              icon: Icons.link,
              label: 'Connect',
              onPressed: () {},
            ),
          if (isConnected)
            _QuickActionButton(
              icon: Icons.link_off,
              label: 'Disconnect',
              onPressed: () {},
            ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: HermesTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Quick Actions'),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.9,
          children: const [
            _QuickActionItem(icon: Icons.terminal, label: 'Console', color: HermesTheme.primaryBlue),
            _QuickActionItem(icon: Icons.memory, label: 'Memory', color: HermesTheme.secondaryPurple),
            _QuickActionItem(icon: Icons.schedule, label: 'Cron', color: HermesTheme.warningAmber),
            _QuickActionItem(icon: Icons.extension, label: 'Tools', color: HermesTheme.successGreen),
            _QuickActionItem(icon: Icons.article, label: 'Logs', color: HermesTheme.errorRed),
            _QuickActionItem(icon: Icons.hub, label: 'Gateway', color: HermesTheme.primaryBlue),
            _QuickActionItem(icon: Icons.file_copy, label: 'Files', color: HermesTheme.secondaryPurple),
            _QuickActionItem(icon: Icons.speed, label: 'Status', color: HermesTheme.warningAmber),
          ],
        ),
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      onTap: () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: HermesTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  const _SectionHeader({required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: CachedTextStyle.headline3),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: const Text('View All'),
          ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  final int index;

  const _SessionCard({required this.index});

  @override
  Widget build(BuildContext context) {
    // Sample data
    final sessions = [
      ('hermes-agent-001', 'Production Server', '2h ago', '45 commands'),
      ('hermes-dev-002', 'Development VM', '1d ago', '23 commands'),
      ('hermes-test-003', 'Test Environment', '3d ago', '12 commands'),
    ];

    final (nodeId, nodeName, timeAgo, commands) = sessions[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        onTap: () {},
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: HermesTheme.primaryBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.computer,
                color: HermesTheme.primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nodeName, style: CachedTextStyle.label.copyWith(color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(
                    nodeId,
                    style: CachedTextStyle.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(timeAgo, style: CachedTextStyle.caption),
                const SizedBox(height: 2),
                Text(commands, style: CachedTextStyle.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemStatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: HermesTheme.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text('System Stats', style: CachedTextStyle.headline3),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _StatItem(label: 'CPU', value: '24%', color: HermesTheme.primaryBlue)),
              Expanded(child: _StatItem(label: 'Memory', value: '1.2GB', color: HermesTheme.successGreen)),
              Expanded(child: _StatItem(label: 'Threads', value: '12', color: HermesTheme.warningAmber)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: CachedTextStyle.caption),
      ],
    );
  }
}
