import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
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
    final tasks = ref.watch(appStateProvider).cronTasks;
    final notifier = ref.read(appStateProvider.notifier);

    final visible = _showDisabled ? tasks : tasks.where((t) => t.enabled).toList();
    final failedCount = tasks.where((t) => t.lastStatus == 'failed').length;
    final filterEnabled = (bool v) => tasks.where((t) => t.enabled).length;

    return Scaffold(
      backgroundColor: HermesTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: HermesTheme.backgroundBlack,
        title: const Text('Automation & Cron'),
        actions: [
          IconButton(
            onPressed: () => _showExecutionHistory(context, notifier),
            icon: const Icon(Icons.history),
            tooltip: 'Execution History',
          ),
        ],
      ),
      body: Column(
        children: [
          _AutomationHeader(total: tasks.length, failed: failedCount, runsToday: tasks.length * 8),
          _QuickActions(notifier: notifier),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Scheduled Tasks (${visible.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Row(
                  children: [
                    const Text('Show disabled', style: TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
                    Switch(value: _showDisabled, onChanged: (v) => setState(() => _showDisabled = v)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: visible.isEmpty
                ? const Center(child: Text('No tasks. Tap + to add one.', style: TextStyle(color: HermesTheme.textSecondary)))
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: visible.map((t) => _CronTaskCard(task: t, notifier: notifier)).toList(),
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

  void _showExecutionHistory(BuildContext context, AppStateNotifier notifier) {
    final runs = ref.read(appStateProvider).cronTasks.where((t) => t.lastRun != null).toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesTheme.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(16),
          children: [
            const Center(child: Text('Execution History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
            const SizedBox(height: 12),
            if (runs.isEmpty) const Text('No executions yet.', style: TextStyle(color: HermesTheme.textSecondary)),
            ...runs.map((t) => ListTile(
                  leading: Icon(t.lastStatus == 'failed' ? Icons.error : Icons.check_circle,
                      color: t.lastStatus == 'failed' ? HermesTheme.errorRed : HermesTheme.successGreen),
                  title: Text(t.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Text('${t.lastRun!.relativeTime} · ${t.lastStatus}', style: const TextStyle(color: HermesTheme.textSecondary)),
                )),
          ],
        ),
      ),
    );
  }

  void _showAddCronDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesTheme.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _AddCronTaskSheet(
        onAdd: (t) => ref.read(appStateProvider.notifier).addCronTask(t),
      ),
    );
  }
}

class _AutomationHeader extends StatelessWidget {
  final int total;
  final int failed;
  final int runsToday;
  const _AutomationHeader({required this.total, required this.failed, required this.runsToday});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [HermesTheme.primaryBlue.withOpacity(0.2), HermesTheme.secondaryPurple.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HermesTheme.primaryBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: HermesTheme.primaryBlue.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.schedule, color: HermesTheme.primaryBlue, size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Automation Engine', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 4),
                    Text('Schedule tasks with natural language', style: TextStyle(fontSize: 13, color: HermesTheme.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: HermesTheme.successGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: HermesTheme.successGreen),
                    SizedBox(width: 6),
                    Text('Active', style: TextStyle(fontSize: 12, color: HermesTheme.successGreen, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _AutomationStat(icon: Icons.check_circle_outline, value: '$total', label: 'Active', color: HermesTheme.successGreen),
              Container(width: 1, height: 30, color: HermesTheme.surfaceOverlay),
              _AutomationStat(icon: Icons.error_outline, value: '$failed', label: 'Failed', color: HermesTheme.errorRed),
              Container(width: 1, height: 30, color: HermesTheme.surfaceOverlay),
              _AutomationStat(icon: Icons.schedule, value: '$runsToday', label: 'Runs Today', color: HermesTheme.primaryBlue),
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
  const _AutomationStat({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: HermesTheme.textSecondary)),
        ],
      );
}

class _QuickActions extends StatelessWidget {
  final AppStateNotifier notifier;
  const _QuickActions({required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _QuickActionButton(icon: Icons.description, label: 'Daily Report', onTap: _run('Generate daily report')),
            _QuickActionButton(icon: Icons.backup, label: 'Auto Backup', onTap: _run('Trigger backup')),
            _QuickActionButton(icon: Icons.health_and_safety, label: 'Health Check', onTap: _run('Run health check')),
            _QuickActionButton(icon: Icons.notifications, label: 'Reminder', onTap: _run('Send reminder')),
          ],
        ),
      ),
    );
  }

  VoidCallback _run(String cmd) => () => notifier.addToolLog(
        ToolLog(tool: 'automation', command: cmd, status: 'success', duration: '0ms', timestamp: DateTime.now()),
      );
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickActionButton({required this.icon, required this.label, required this.onTap});

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
                Text(label, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CronTaskCard extends StatelessWidget {
  final CronTask task;
  final AppStateNotifier notifier;
  const _CronTaskCard({required this.task, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final freq = _frequencyLabel(task.expression);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: HermesTheme.surfaceDark, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(gradient: HermesTheme.primaryGradient, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: HermesTheme.primaryBlue.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                          child: Text(freq, style: const TextStyle(fontSize: 10, color: HermesTheme.primaryBlue)),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.schedule, size: 12, color: HermesTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(task.expression, style: const TextStyle(fontSize: 11, color: HermesTheme.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              Switch(value: task.enabled, onChanged: (v) => notifier.toggleCronTask(task.id, v)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: HermesTheme.surfaceElevated, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.text_snippet, size: 16, color: HermesTheme.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(task.description, style: HermesTheme.codeStyle.copyWith(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _TaskMetaInfo(icon: Icons.play_arrow, value: task.lastRun == null ? '—' : task.lastRun!.relativeTime, label: 'last', color: HermesTheme.textSecondary),
              const SizedBox(width: 16),
              _TaskMetaInfo(
                icon: task.lastStatus == 'failed' ? Icons.error : Icons.check_circle,
                value: task.lastStatus ?? 'never',
                label: 'status',
                color: task.lastStatus == 'failed' ? HermesTheme.errorRed : HermesTheme.successGreen,
              ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: HermesTheme.textSecondary),
                color: HermesTheme.surfaceElevated,
                onSelected: (value) {
                  if (value == 'run') notifier.executeCronTask(task.id);
                  if (value == 'delete') notifier.removeCronTask(task.id);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'run', child: Row(children: [Icon(Icons.play_arrow, size: 18), SizedBox(width: 8), Text('Run Now')])),
                  PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: HermesTheme.errorRed), SizedBox(width: 8), Text('Delete', style: TextStyle(color: HermesTheme.errorRed))])),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _frequencyLabel(String expr) {
    if (expr.contains('* * *')) return 'Hourly';
    if (expr.contains('* * 1-5')) return 'Weekdays';
    if (expr.contains('0 2 * * 0')) return 'Weekly';
    if (expr.contains('0 18 * * *')) return 'Daily';
    return 'Custom';
  }
}

class _TaskMetaInfo extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _TaskMetaInfo({required this.icon, required this.value, required this.label, this.color = HermesTheme.textSecondary});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(width: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: HermesTheme.textTertiary)),
        ],
      );
}

/// Add Cron Task Sheet
class _AddCronTaskSheet extends StatefulWidget {
  final ValueChanged<CronTask> onAdd;
  const _AddCronTaskSheet({required this.onAdd});

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

  String _expression() {
    switch (_scheduleType) {
      case 'hourly':
        return '0 * * * *';
      case 'weekly':
        return '0 ${_selectedTime.hour} * * 0';
      case 'monthly':
        return '0 ${_selectedTime.hour} 1 * *';
      default:
        return '0 ${_selectedTime.hour} * * *';
    }
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
                decoration: BoxDecoration(color: HermesTheme.surfaceOverlay, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(gradient: HermesTheme.primaryGradient, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.add_task, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text('Create New Task', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _taskNameController,
              decoration: const InputDecoration(labelText: 'Task Name', hintText: 'e.g., Daily Backup'),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Natural Language Command', hintText: 'e.g., Backup database and send report to email'),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text('Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(label: const Text('Hourly'), selected: _scheduleType == 'hourly', onSelected: (s) => s ? setState(() => _scheduleType = 'hourly') : null),
                ChoiceChip(label: const Text('Daily'), selected: _scheduleType == 'daily', onSelected: (s) => s ? setState(() => _scheduleType = 'daily') : null),
                ChoiceChip(label: const Text('Weekly'), selected: _scheduleType == 'weekly', onSelected: (s) => s ? setState(() => _scheduleType = 'weekly') : null),
                ChoiceChip(label: const Text('Monthly'), selected: _scheduleType == 'monthly', onSelected: (s) => s ? setState(() => _scheduleType = 'monthly') : null),
              ],
            ),
            if (_scheduleType != 'hourly') ...[
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time, color: HermesTheme.primaryBlue),
                title: const Text('Time', style: TextStyle(color: Colors.white)),
                subtitle: Text(_selectedTime.format(context), style: const TextStyle(color: HermesTheme.textSecondary)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final time = await showTimePicker(context: context, initialTime: _selectedTime);
                  if (time != null) setState(() => _selectedTime = time);
                },
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final name = _taskNameController.text.trim();
                  if (name.isEmpty) return;
                  widget.onAdd(CronTask.create(
                    name: name,
                    expression: _expression(),
                    description: _descriptionController.text.trim().isEmpty ? name : _descriptionController.text.trim(),
                  ));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task created successfully'), behavior: SnackBarBehavior.floating),
                  );
                },
                child: const Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Text('Create Task')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
