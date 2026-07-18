import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme/hermes_theme.dart';

/// Cron Automation Screen - Schedule Tasks
class AutomationScreen extends ConsumerStatefulWidget {
  const AutomationScreen({super.key});

  @override
  ConsumerState<AutomationScreen> createState() => _AutomationScreenState();
}

class _AutomationScreenState extends ConsumerState<AutomationScreen> {
  bool _showDisabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HermesTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: HermesTheme.backgroundBlack,
        title: const Text('Automation & Cron'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.history),
            tooltip: 'Execution History',
          ),
        ],
      ),
      body: Column(
        children: [
          _AutomationHeader(),
          _QuickActions(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scheduled Tasks',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      'Show disabled',
                      style: TextStyle(
                        fontSize: 12,
                        color: HermesTheme.textSecondary,
                      ),
                    ),
                    Switch(
                      value: _showDisabled,
                      onChanged: (value) => setState(() => _showDisabled = value),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                _CronTaskCard(),
                _CronTaskCard(),
                _CronTaskCard(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCronDialog,
        backgroundColor: HermesTheme.primaryBlue,
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }

  void _showAddCronDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesTheme.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _AddCronTaskSheet(),
    );
  }
}

class _AutomationHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HermesTheme.primaryBlue.withOpacity(0.2),
            HermesTheme.secondaryPurple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: HermesTheme.primaryBlue.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: HermesTheme.primaryBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: HermesTheme.primaryBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Automation Engine',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Schedule tasks with natural language',
                      style: TextStyle(
                        fontSize: 13,
                        color: HermesTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: HermesTheme.successGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: HermesTheme.successGreen,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 12,
                        color: HermesTheme.successGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _AutomationStat(
                icon: Icons.check_circle_outline,
                value: '12',
                label: 'Active',
                color: HermesTheme.successGreen,
              ),
              Container(
                width: 1,
                height: 30,
                color: HermesTheme.surfaceOverlay,
              ),
              _AutomationStat(
                icon: Icons.error_outline,
                value: '1',
                label: 'Failed',
                color: HermesTheme.errorRed,
              ),
              Container(
                width: 1,
                height: 30,
                color: HermesTheme.surfaceOverlay,
              ),
              _AutomationStat(
                icon: Icons.schedule,
                value: '47',
                label: 'Runs Today',
                color: HermesTheme.primaryBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AutomationStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _AutomationStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: HermesTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _QuickActionButton(
              icon: Icons.description,
              label: 'Daily Report',
              onTap: () {},
            ),
            _QuickActionButton(
              icon: Icons.backup,
              label: 'Auto Backup',
              onTap: () {},
            ),
            _QuickActionButton(
              icon: Icons.health_and_safety,
              label: 'Health Check',
              onTap: () {},
            ),
            _QuickActionButton(
              icon: Icons.notifications,
              label: 'Reminder',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: HermesTheme.primaryBlue, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
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

class _CronTaskCard extends StatelessWidget {
  const _CronTaskCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: HermesTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Standup Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: HermesTheme.primaryBlue.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Daily',
                            style: TextStyle(
                              fontSize: 10,
                              color: HermesTheme.primaryBlue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.schedule,
                          size: 12,
                          color: HermesTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '09:00 AM',
                          style: TextStyle(
                            fontSize: 11,
                            color: HermesTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Switch(
                value: true,
                onChanged: (value) {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: HermesTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.text_snippet,
                  size: 16,
                  color: HermesTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Generate daily standup report and send to Slack channel',
                    style: HermesTheme.codeStyle.copyWith(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _TaskMetaInfo(
                icon: Icons.play_arrow,
                value: '234',
                label: 'runs',
              ),
              const SizedBox(width: 16),
              _TaskMetaInfo(
                icon: Icons.check_circle,
                value: '231',
                label: 'success',
                color: HermesTheme.successGreen,
              ),
              const SizedBox(width: 16),
              _TaskMetaInfo(
                icon: Icons.error,
                value: '3',
                label: 'failed',
                color: HermesTheme.errorRed,
              ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: HermesTheme.textSecondary,
                ),
                color: HermesTheme.surfaceElevated,
                onSelected: (value) {},
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'run',
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow, size: 18),
                        SizedBox(width: 8),
                        Text('Run Now'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logs',
                    child: Row(
                      children: [
                        Icon(Icons.history, size: 18),
                        SizedBox(width: 8),
                        Text('View Logs'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: HermesTheme.errorRed),
                        const SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: HermesTheme.errorRed)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskMetaInfo extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _TaskMetaInfo({
    required this.icon,
    required this.value,
    required this.label,
    this.color = HermesTheme.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: HermesTheme.textTertiary,
          ),
        ),
      ],
    );
  }
}

/// Add Cron Task Sheet
class _AddCronTaskSheet extends StatefulWidget {
  const _AddCronTaskSheet();

  @override
  State<_AddCronTaskSheet> createState() => _AddCronTaskSheetState();
}

class _AddCronTaskSheetState extends State<_AddCronTaskSheet> {
  final _taskNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _scheduleType = 'daily';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: HermesTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_task, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Create New Task',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _taskNameController,
              decoration: const InputDecoration(
                labelText: 'Task Name',
                hintText: 'e.g., Daily Backup',
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Natural Language Command',
                hintText: 'e.g., Backup database and send report to email',
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              'Schedule',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Hourly'),
                  selected: _scheduleType == 'hourly',
                  onSelected: (selected) {
                    if (selected) setState(() => _scheduleType = 'hourly');
                  },
                ),
                ChoiceChip(
                  label: const Text('Daily'),
                  selected: _scheduleType == 'daily',
                  onSelected: (selected) {
                    if (selected) setState(() => _scheduleType = 'daily');
                  },
                ),
                ChoiceChip(
                  label: const Text('Weekly'),
                  selected: _scheduleType == 'weekly',
                  onSelected: (selected) {
                    if (selected) setState(() => _scheduleType = 'weekly');
                  },
                ),
                ChoiceChip(
                  label: const Text('Monthly'),
                  selected: _scheduleType == 'monthly',
                  onSelected: (selected) {
                    if (selected) setState(() => _scheduleType = 'monthly');
                  },
                ),
              ],
            ),
            if (_scheduleType != 'hourly') ...[
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time, color: HermesTheme.primaryBlue),
                title: const Text('Time', style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  _selectedTime.format(context),
                  style: const TextStyle(color: HermesTheme.textSecondary),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (time != null) {
                    setState(() => _selectedTime = time);
                  }
                },
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Notification',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Notify on completion',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Send notification when task completes',
                style: TextStyle(
                  fontSize: 12,
                  color: HermesTheme.textSecondary,
                ),
              ),
              value: true,
              onChanged: (value) {},
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task created successfully'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('Create Task'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
