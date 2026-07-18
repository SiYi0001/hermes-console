import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme/hermes_theme.dart';

/// Profile & Identity Management Screen
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HermesTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: HermesTheme.backgroundBlack,
        title: const Text('Profile & Identity'),
        actions: [
          IconButton(
            onPressed: _editProfile,
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ProfileHeader(),
            const SizedBox(height: 24),
            _UsageStatsCard(),
            const SizedBox(height: 24),
            _IdentitiesSection(),
            const SizedBox(height: 24),
            _SecuritySection(),
            const SizedBox(height: 24),
            _DataSection(),
          ],
        ),
      ),
    );
  }

  void _editProfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesTheme.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _EditProfileSheet(),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HermesTheme.primaryBlue.withOpacity(0.2),
            HermesTheme.secondaryPurple.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: HermesTheme.primaryBlue.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: HermesTheme.primaryGradient,
                ),
                child: const CircleAvatar(
                  radius: 48,
                  backgroundColor: HermesTheme.backgroundBlack,
                  child: Icon(
                    Icons.person,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: HermesTheme.successGreen,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: HermesTheme.backgroundBlack,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'John Developer',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: HermesTheme.primaryBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Pro Member',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: HermesTheme.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'john@hermes.dev',
            style: TextStyle(
              fontSize: 14,
              color: HermesTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ProfileStat(label: 'Sessions', value: '127'),
              const SizedBox(width: 32),
              _ProfileStat(label: 'Commands', value: '2.4K'),
              const SizedBox(width: 32),
              _ProfileStat(label: 'Skills', value: '18'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: HermesTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _UsageStatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Usage Statistics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View Details'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _UsageProgressItem(
            label: 'API Calls',
            current: 12450,
            max: 20000,
            color: HermesTheme.primaryBlue,
          ),
          const SizedBox(height: 12),
          _UsageProgressItem(
            label: 'Storage',
            current: 845,
            max: 2048,
            unit: 'MB',
            color: HermesTheme.successGreen,
          ),
          const SizedBox(height: 12),
          _UsageProgressItem(
            label: 'Bandwidth',
            current: 2.4,
            max: 10,
            unit: 'GB',
            color: HermesTheme.warningAmber,
          ),
        ],
      ),
    );
  }
}

class _UsageProgressItem extends StatelessWidget {
  final String label;
  final num current;
  final num max;
  final String unit;
  final Color color;

  const _UsageProgressItem({
    required this.label,
    required this.current,
    required this.max,
    this.unit = '',
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = current / max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: HermesTheme.textSecondary,
              ),
            ),
            Text(
              '$current / $max $unit',
              style: const TextStyle(
                fontSize: 12,
                color: HermesTheme.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: HermesTheme.surfaceElevated,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class _IdentitiesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final identities = [
      _Identity(
        name: 'Work Mode',
        icon: Icons.work,
        color: const Color(0xFF3B82F6),
        isActive: true,
      ),
      _Identity(
        name: 'Personal',
        icon: Icons.person,
        color: const Color(0xFF8B5CF6),
        isActive: false,
      ),
      _Identity(
        name: 'Development',
        icon: Icons.code,
        color: const Color(0xFF22C55E),
        isActive: false,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Identities',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...identities.map((identity) => _IdentityCard(identity: identity)),
      ],
    );
  }
}

class _IdentityCard extends StatelessWidget {
  final _Identity identity;

  const _IdentityCard({required this.identity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: identity.isActive
            ? Border.all(color: identity.color.withOpacity(0.5))
            : null,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: identity.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(identity.icon, color: identity.color, size: 20),
        ),
        title: Text(
          identity.name,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        trailing: identity.isActive
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: identity.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: HermesTheme.successGreen,
                  ),
                ),
              )
            : TextButton(
                onPressed: () {},
                child: const Text('Switch'),
              ),
      ),
    );
  }
}

class _SecuritySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Security',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: HermesTheme.surfaceDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _SecurityItem(
                icon: Icons.key,
                title: 'API Keys',
                subtitle: 'Manage your API keys',
                onTap: () {},
              ),
              const Divider(color: HermesTheme.surfaceOverlay, height: 1),
              _SecurityItem(
                icon: Icons.fingerprint,
                title: 'Biometric Login',
                subtitle: 'Face ID / Fingerprint',
                trailing: Switch(value: true, onChanged: (_) {}),
                onTap: () {},
              ),
              const Divider(color: HermesTheme.surfaceOverlay, height: 1),
              _SecurityItem(
                icon: Icons.lock,
                title: 'Change Password',
                subtitle: 'Update your password',
                onTap: () {},
              ),
              const Divider(color: HermesTheme.surfaceOverlay, height: 1),
              _SecurityItem(
                icon: Icons.devices,
                title: 'Active Sessions',
                subtitle: '2 devices logged in',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SecurityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SecurityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: HermesTheme.primaryBlue),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: HermesTheme.textSecondary),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: HermesTheme.textSecondary),
      onTap: onTap,
    );
  }
}

class _DataSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data & Privacy',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: HermesTheme.surfaceDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _DataItem(
                icon: Icons.download,
                title: 'Export Data',
                subtitle: 'Download all your data',
                onTap: () {},
              ),
              const Divider(color: HermesTheme.surfaceOverlay, height: 1),
              _DataItem(
                icon: Icons.cloud_sync,
                title: 'Sync Settings',
                subtitle: 'Cloud backup preferences',
                onTap: () {},
              ),
              const Divider(color: HermesTheme.surfaceOverlay, height: 1),
              _DataItem(
                icon: Icons.delete_forever,
                title: 'Delete Account',
                subtitle: 'Permanently delete all data',
                isDestructive: true,
                onTap: () => _confirmDelete(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HermesTheme.surfaceDark,
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete all your data including memories, skills, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: HermesTheme.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _DataItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDestructive;
  final VoidCallback onTap;

  const _DataItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? HermesTheme.errorRed : HermesTheme.primaryBlue,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? HermesTheme.errorRed : Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: HermesTheme.textSecondary),
      ),
      trailing: const Icon(Icons.chevron_right, color: HermesTheme.textSecondary),
      onTap: onTap,
    );
  }
}

/// Edit Profile Sheet
class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet();

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _nameController = TextEditingController(text: 'John Developer');
  final _emailController = TextEditingController(text: 'john@hermes.dev');
  final _bioController = TextEditingController(text: 'Full-stack developer');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: HermesTheme.surfaceOverlay,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: HermesTheme.primaryGradient,
                    ),
                    child: const CircleAvatar(
                      radius: 48,
                      backgroundColor: HermesTheme.backgroundBlack,
                      child: Icon(
                        Icons.person,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: HermesTheme.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Bio',
                prefixIcon: Icon(Icons.info_outline),
                alignLabelWithHint: true,
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Models
class _Identity {
  final String name;
  final IconData icon;
  final Color color;
  final bool isActive;

  _Identity({
    required this.name,
    required this.icon,
    required this.color,
    required this.isActive,
  });
}
