import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../core/utils/utils.dart';
import '../../shared/theme/hermes_theme.dart';

/// Memory Management Screen - Hermes Long-term Memory System
class MemoryScreen extends ConsumerStatefulWidget {
  const MemoryScreen({super.key});

  @override
  ConsumerState<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends ConsumerState<MemoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memories = ref.watch(appStateProvider).memories;
    final skills = ref.watch(appStateProvider).skills;

    return Scaffold(
      backgroundColor: HermesTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: HermesTheme.backgroundBlack,
        title: const Text('Memory & Context'),
        actions: [
          IconButton(
            onPressed: _syncMemory,
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'Sync Memory',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: HermesTheme.primaryBlue,
          labelColor: HermesTheme.primaryBlue,
          unselectedLabelColor: HermesTheme.textSecondary,
          tabs: const [
            Tab(text: 'Memories'),
            Tab(text: 'Skills'),
            Tab(text: 'Context'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MemoriesTab(memories: memories, notifier: ref.read(appStateProvider.notifier)),
          _SkillsTab(skills: skills),
          const _ContextTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewMemory,
        backgroundColor: HermesTheme.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _syncMemory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Syncing memory with agent...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addNewMemory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesTheme.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddMemorySheet(
        onSave: (m) => ref.read(appStateProvider.notifier).addMemory(m),
      ),
    );
  }
}

/// Memories Tab
class _MemoriesTab extends StatelessWidget {
  final List<MemoryItem> memories;
  final AppStateNotifier notifier;

  const _MemoriesTab({required this.memories, required this.notifier});

  @override
  Widget build(BuildContext context) {
    if (memories.isEmpty) {
      return const Center(
        child: Text('No memories yet. Tap + to add one.', style: TextStyle(color: HermesTheme.textSecondary)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: memories.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _MemorySummaryCard(memories: memories);
        final m = memories[index - 1];
        return _MemoryCard(
          memory: m,
          onEdit: () => _showEdit(context, m),
          onDelete: () => notifier.removeMemory(m.id),
        );
      },
    );
  }

  void _showEdit(BuildContext context, MemoryItem m) {
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesTheme.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddMemorySheet(
        initial: m,
        onSave: (updated) => notifier.updateMemory(updated),
      ),
    );
  }
}

class _MemorySummaryCard extends StatelessWidget {
  final List<MemoryItem> memories;

  const _MemorySummaryCard({required this.memories});

  @override
  Widget build(BuildContext context) {
    final avgImportance = memories.isEmpty
        ? 0.0
        : memories.map((m) => m.importance).reduce((a, b) => a + b) / memories.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        border: Border.all(color: HermesTheme.primaryBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: HermesTheme.primaryBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.psychology_rounded, color: HermesTheme.primaryBlue, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Memory Summary',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Long-term knowledge base',
                        style: TextStyle(fontSize: 13, color: HermesTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: 'Total', value: '${memories.length}'),
              _StatItem(label: 'Avg Importance', value: avgImportance.toStringAsFixed(1)),
              _StatItem(label: 'Categories', value: '${memories.map((m) => m.category).toSet().length}'),
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
  const _StatItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: HermesTheme.primaryBlue)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
        ],
      );
}

class _MemoryCard extends StatelessWidget {
  final MemoryItem memory;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MemoryCard({required this.memory, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: HermesTheme.surfaceDark, borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: _getCategoryColor(memory.category).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
          child: Icon(_getCategoryIcon(memory.category), color: _getCategoryColor(memory.category), size: 20),
        ),
        title: Text(memory.title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(memory.category, style: TextStyle(fontSize: 11, color: _getCategoryColor(memory.category))),
            const SizedBox(height: 4),
            Row(
              children: [
                _ImportanceIndicator(importance: memory.importance),
                const SizedBox(width: 8),
                Text(memory.timestamp.relativeTime, style: const TextStyle(fontSize: 11, color: HermesTheme.textTertiary)),
              ],
            ),
          ],
        ),
        children: [
          Text(memory.content, style: const TextStyle(fontSize: 14, color: HermesTheme.textSecondary, height: 1.5)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(onPressed: onEdit, icon: const Icon(Icons.edit, size: 16), label: const Text('Edit')),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: HermesTheme.errorRed),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Preferences':
        return HermesTheme.primaryBlue;
      case 'Technical':
        return HermesTheme.successGreen;
      case 'Workstyle':
        return HermesTheme.warningAmber;
      default:
        return HermesTheme.secondaryPurple;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Preferences':
        return Icons.tune_rounded;
      case 'Technical':
        return Icons.code_rounded;
      case 'Workstyle':
        return Icons.schedule_rounded;
      default:
        return Icons.bookmark_rounded;
    }
  }
}

class _ImportanceIndicator extends StatelessWidget {
  final int importance;
  const _ImportanceIndicator({required this.importance});
  @override
  Widget build(BuildContext context) => Row(
        children: List.generate(5, (index) {
          return Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index < importance ? HermesTheme.primaryBlue : HermesTheme.surfaceOverlay,
            ),
          );
        }),
      );
}

/// Skills Tab
class _SkillsTab extends StatelessWidget {
  final List<SkillItem> skills;
  const _SkillsTab({required this.skills});

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      return const Center(child: Text('No skills yet.', style: TextStyle(color: HermesTheme.textSecondary)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: skills.length,
      itemBuilder: (context, index) => _SkillCard(skill: skills[index]),
    );
  }
}

class _SkillCard extends StatelessWidget {
  final SkillItem skill;
  const _SkillCard({required this.skill});

  @override
  Widget build(BuildContext context) {
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
                child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(skill.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: HermesTheme.primaryBlue.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                      child: Text(skill.category, style: const TextStyle(fontSize: 10, color: HermesTheme.primaryBlue)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${skill.usageCount}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: HermesTheme.successGreen)),
                  const Text('uses', style: TextStyle(fontSize: 10, color: HermesTheme.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(skill.description, style: const TextStyle(fontSize: 13, color: HermesTheme.textSecondary)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: HermesTheme.textTertiary),
              const SizedBox(width: 4),
              Text('Last used: ${skill.lastUsed.relativeTime}',
                  style: const TextStyle(fontSize: 11, color: HermesTheme.textTertiary)),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('Use Skill')),
            ],
          ),
        ],
      ),
    );
  }
}

/// Context Tab
class _ContextTab extends StatelessWidget {
  const _ContextTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _ContextSummaryCard(),
          SizedBox(height: 16),
          _ActiveContextCard(),
          SizedBox(height: 16),
          _ContextVariablesCard(),
        ],
      ),
    );
  }
}

class _ContextSummaryCard extends StatelessWidget {
  const _ContextSummaryCard();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: HermesTheme.surfaceDark, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Context Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _ContextStat(icon: Icons.article, label: 'Tokens', value: '12.4K'),
                _ContextStat(icon: Icons.folder, label: 'Files', value: '8'),
                _ContextStat(icon: Icons.history, label: 'History', value: '45'),
              ],
            ),
          ],
        ),
      );
}

class _ContextStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ContextStat({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, color: HermesTheme.primaryBlue, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: const TextStyle(fontSize: 11, color: HermesTheme.textSecondary)),
        ],
      );
}

class _ActiveContextCard extends StatelessWidget {
  const _ActiveContextCard();
  @override
  Widget build(BuildContext context) {
    const contexts = [
      _ActiveContextItem(name: 'Current Project', type: 'Directory', size: '2.3 MB'),
      _ActiveContextItem(name: 'API Config', type: 'File', size: '4 KB'),
      _ActiveContextItem(name: 'User Preferences', type: 'Memory', size: '1 KB'),
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: HermesTheme.surfaceDark, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Active Context', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              TextButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 16), label: const Text('Add')),
            ],
          ),
          const SizedBox(height: 12),
          ...contexts.map((c) => _ContextItemRow(item: c)),
        ],
      ),
    );
  }
}

class _ContextItemRow extends StatelessWidget {
  final _ActiveContextItem item;
  const _ContextItemRow({required this.item});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(item.type == 'Directory' ? Icons.folder : item.type == 'File' ? Icons.insert_drive_file : Icons.psychology,
                color: HermesTheme.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontSize: 14, color: Colors.white)),
                  Text(item.type, style: const TextStyle(fontSize: 11, color: HermesTheme.textSecondary)),
                ],
              ),
            ),
            Text(item.size, style: const TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
            const SizedBox(width: 8),
            const Icon(Icons.close, size: 16, color: HermesTheme.textTertiary),
          ],
        ),
      );
}

class _ContextVariablesCard extends StatelessWidget {
  const _ContextVariablesCard();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: HermesTheme.surfaceDark, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Environment Variables', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                TextButton.icon(onPressed: () {}, icon: const Icon(Icons.edit, size: 16), label: const Text('Edit')),
              ],
            ),
            const SizedBox(height: 12),
            const _EnvVarRow(name: 'NODE_ENV', value: 'development'),
            _EnvVarRow(name: 'API_URL', value: AppConfig.apiUrl),
            const _EnvVarRow(name: 'DEBUG', value: 'true'),
          ],
        ),
      );
}

class _EnvVarRow extends StatelessWidget {
  final String name;
  final String value;
  const _EnvVarRow({required this.name, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: HermesTheme.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(name, style: HermesTheme.codeStyle.copyWith(fontSize: 12, color: HermesTheme.primaryBlue)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(value, style: HermesTheme.codeStyle.copyWith(fontSize: 12, color: HermesTheme.textSecondary), overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );
}

/// Add / Edit Memory Sheet
class _AddMemorySheet extends StatefulWidget {
  final MemoryItem? initial;
  final ValueChanged<MemoryItem> onSave;
  const _AddMemorySheet({this.initial, required this.onSave});

  @override
  State<_AddMemorySheet> createState() => _AddMemorySheetState();
}

class _AddMemorySheetState extends State<_AddMemorySheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late String _selectedCategory;
  late int _importance;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initial?.title ?? '');
    _contentController = TextEditingController(text: widget.initial?.content ?? '');
    _selectedCategory = widget.initial?.category ?? 'General';
    _importance = widget.initial?.importance ?? 3;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
          Text(isEdit ? 'Edit Memory' : 'Add New Memory',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title', hintText: 'Enter memory title'),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Content', hintText: 'Enter memory content'),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Category:', style: TextStyle(color: HermesTheme.textSecondary)),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('General'),
                selected: _selectedCategory == 'General',
                onSelected: (s) => s ? setState(() => _selectedCategory = 'General') : null,
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Technical'),
                selected: _selectedCategory == 'Technical',
                onSelected: (s) => s ? setState(() => _selectedCategory = 'Technical') : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Importance:', style: TextStyle(color: HermesTheme.textSecondary)),
              const Spacer(),
              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => setState(() => _importance = index + 1),
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < _importance ? HermesTheme.primaryBlue : HermesTheme.surfaceOverlay,
                      ),
                      child: index < _importance ? const Icon(Icons.star, size: 14, color: Colors.white) : null,
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final item = widget.initial?.copyWith(
                      title: _titleController.text,
                      content: _contentController.text,
                      category: _selectedCategory,
                      importance: _importance,
                    ) ??
                    MemoryItem.create(
                      title: _titleController.text,
                      content: _contentController.text,
                      category: _selectedCategory,
                      importance: _importance,
                    );
                widget.onSave(item);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEdit ? 'Memory updated' : 'Memory saved successfully'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(isEdit ? 'Save Changes' : 'Save Memory'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveContextItem {
  final String name;
  final String type;
  final String size;
  const _ActiveContextItem({required this.name, required this.type, required this.size});
}

/// Simple app config placeholder so the Env Var row references a real value.
class AppConfig {
  const AppConfig._();
  static const String apiUrl = 'https://api.example.com';
}
