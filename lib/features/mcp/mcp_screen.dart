import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../shared/theme/hermes_theme.dart';

/// MCP Tools Management Screen
class McpScreen extends ConsumerStatefulWidget {
  const McpScreen({super.key});

  @override
  ConsumerState<McpScreen> createState() => _McpScreenState();
}

class _McpScreenState extends ConsumerState<McpScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

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
    final servers = ref.watch(appStateProvider).mcpServers;
    final tools = ref.watch(appStateProvider).builtInTools;
    final logs = ref.watch(appStateProvider).toolLogs;
    final notifier = ref.read(appStateProvider.notifier);

    final filteredServers = _searchQuery.isEmpty
        ? servers
        : servers.where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    final filteredTools = _searchQuery.isEmpty
        ? tools
        : tools.where((t) => t.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    final filteredLogs = _searchQuery.isEmpty
        ? logs
        : logs.where((l) => l.tool.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: HermesTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: HermesTheme.backgroundBlack,
        title: const Text('MCP Tools & Skills'),
        actions: [
          IconButton(
            onPressed: _showAddMcpDialog,
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add MCP Server',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: HermesTheme.primaryBlue,
          labelColor: HermesTheme.primaryBlue,
          unselectedLabelColor: HermesTheme.textSecondary,
          tabs: const [
            Tab(text: 'MCP Servers'),
            Tab(text: 'Built-in Tools'),
            Tab(text: 'Tool Logs'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search tools...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: HermesTheme.surfaceDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _McpServersTab(servers: filteredServers, notifier: notifier),
                _BuiltInToolsTab(tools: filteredTools, notifier: notifier),
                _ToolLogsTab(logs: filteredLogs),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMcpDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddMcpServerDialog(
        onAdd: (s) => ref.read(appStateProvider.notifier).addMcpServer(s),
      ),
    );
  }
}

/// MCP Servers Tab
class _McpServersTab extends StatelessWidget {
  final List<McpServer> servers;
  final AppStateNotifier notifier;

  const _McpServersTab({required this.servers, required this.notifier});

  @override
  Widget build(BuildContext context) {
    if (servers.isEmpty) {
      return const Center(child: Text('No MCP servers. Tap + to add one.', style: TextStyle(color: HermesTheme.textSecondary)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: servers.length,
      itemBuilder: (context, index) => _McpServerCard(server: servers[index], notifier: notifier),
    );
  }
}

class _McpServerCard extends StatelessWidget {
  final McpServer server;
  final AppStateNotifier notifier;
  const _McpServerCard({required this.server, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final isLocal = server.type == 'local';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: server.status == 'active' ? Border.all(color: HermesTheme.successGreen.withOpacity(0.3)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isLocal ? HermesTheme.primaryBlue : HermesTheme.secondaryPurple).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isLocal ? Icons.computer : Icons.cloud_outlined,
                  color: isLocal ? HermesTheme.primaryBlue : HermesTheme.secondaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(server.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (isLocal ? HermesTheme.primaryBlue : HermesTheme.secondaryPurple).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(server.type, style: TextStyle(fontSize: 10, color: isLocal ? HermesTheme.primaryBlue : HermesTheme.secondaryPurple)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: server.status == 'active' ? HermesTheme.successGreen : HermesTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(server.status,
                            style: TextStyle(fontSize: 11, color: server.status == 'active' ? HermesTheme.successGreen : HermesTheme.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: HermesTheme.textSecondary),
                color: HermesTheme.surfaceElevated,
                onSelected: (value) {
                  if (value == 'edit') {
                    notifier.addToolLog(ToolLog(tool: server.name, command: 'edit config', status: 'success', duration: '0ms', timestamp: DateTime.now()));
                  } else if (value == 'restart') {
                    notifier.restartMcpServer(server.id);
                  } else if (value == 'delete') {
                    notifier.removeMcpServer(server.id);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                  PopupMenuItem(value: 'restart', child: Row(children: [Icon(Icons.refresh, size: 18), SizedBox(width: 8), Text('Restart')])),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [Icon(Icons.delete, size: 18, color: HermesTheme.errorRed), SizedBox(width: 8), Text('Delete', style: TextStyle(color: HermesTheme.errorRed))]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.extension, size: 14, color: HermesTheme.textTertiary),
                  const SizedBox(width: 4),
                  Text('${server.toolsCount} tools', style: const TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: HermesTheme.textTertiary),
                  const SizedBox(width: 4),
                  Text('Last used: ${server.lastUsed.relativeTime}', style: const TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Built-in Tools Tab
class _BuiltInToolsTab extends StatelessWidget {
  final List<ToolItem> tools;
  final AppStateNotifier notifier;
  const _BuiltInToolsTab({required this.tools, required this.notifier});

  @override
  Widget build(BuildContext context) {
    if (tools.isEmpty) {
      return const Center(child: Text('No tools.', style: TextStyle(color: HermesTheme.textSecondary)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: tools.length,
      itemBuilder: (context, index) => _ToolCard(tool: tools[index], notifier: notifier),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final ToolItem tool;
  final AppStateNotifier notifier;
  const _ToolCard({required this.tool, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: HermesTheme.surfaceDark, borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        value: tool.enabled,
        onChanged: (v) => notifier.toggleToolEnabled(tool.name, v),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: _getCategoryColor(tool.category).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
          child: Icon(_getCategoryColor(tool.category), color: tool.enabled ? _getCategoryColor(tool.category) : HermesTheme.textSecondary, size: 20),
        ),
        title: Text(tool.name,
            style: TextStyle(fontWeight: FontWeight.w600, color: tool.enabled ? Colors.white : HermesTheme.textSecondary)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tool.description, style: const TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: HermesTheme.surfaceElevated, borderRadius: BorderRadius.circular(4)),
                  child: Text(tool.category, style: const TextStyle(fontSize: 10, color: HermesTheme.textTertiary)),
                ),
                const SizedBox(width: 8),
                Text('${tool.usageCount} uses', style: const TextStyle(fontSize: 10, color: HermesTheme.textTertiary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'System':
        return HermesTheme.errorRed;
      case 'File':
        return HermesTheme.primaryBlue;
      case 'Network':
        return HermesTheme.successGreen;
      case 'Automation':
        return HermesTheme.warningAmber;
      case 'Media':
        return HermesTheme.secondaryPurple;
      default:
        return HermesTheme.textSecondary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'System':
        return Icons.terminal;
      case 'File':
        return Icons.folder;
      case 'Network':
        return Icons.language;
      case 'Automation':
        return Icons.smart_toy;
      case 'Media':
        return Icons.image;
      default:
        return Icons.extension;
    }
  }
}

/// Tool Logs Tab
class _ToolLogsTab extends StatelessWidget {
  final List<ToolLog> logs;
  const _ToolLogsTab({required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Center(child: Text('No tool logs yet.', style: TextStyle(color: HermesTheme.textSecondary)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: logs.length,
      itemBuilder: (context, index) => _ToolLogCard(log: logs[index]),
    );
  }
}

class _ToolLogCard extends StatelessWidget {
  final ToolLog log;
  const _ToolLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final ok = log.status == 'success';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: ok ? null : Border.all(color: HermesTheme.errorRed.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: HermesTheme.primaryBlue.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                child: Text(log.tool, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: HermesTheme.primaryBlue)),
              ),
              const SizedBox(width: 8),
              Icon(ok ? Icons.check_circle : Icons.error, size: 14, color: ok ? HermesTheme.successGreen : HermesTheme.errorRed),
              const Spacer(),
              Text(log.duration, style: const TextStyle(fontSize: 11, color: HermesTheme.textSecondary)),
              const SizedBox(width: 8),
              Text(log.timestamp.relativeTime, style: const TextStyle(fontSize: 11, color: HermesTheme.textTertiary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(log.command, style: HermesTheme.codeStyle.copyWith(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

/// Add MCP Server Dialog
class _AddMcpServerDialog extends StatefulWidget {
  final ValueChanged<McpServer> onAdd;
  const _AddMcpServerDialog({required this.onAdd});

  @override
  State<_AddMcpServerDialog> createState() => _AddMcpServerDialogState();
}

class _AddMcpServerDialogState extends State<_AddMcpServerDialog> {
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  String _serverType = 'local';

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: HermesTheme.surfaceDark,
      title: const Text('Add MCP Server'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Server Name', hintText: 'e.g., GitHub API'),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text('Server Type', style: TextStyle(fontSize: 14, color: HermesTheme.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Local'),
                  selected: _serverType == 'local',
                  onSelected: (s) => s ? setState(() => _serverType = 'local') : null,
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Remote'),
                  selected: _serverType == 'remote',
                  onSelected: (s) => s ? setState(() => _serverType = 'remote') : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: _serverType == 'local' ? 'Command' : 'URL',
                hintText: _serverType == 'local'
                    ? 'e.g., npx @modelcontextprotocol/server-filesystem'
                    : 'e.g., https://mcp.example.com/server',
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            widget.onAdd(McpServer.create(name: name, type: _serverType));
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('MCP Server added successfully'), behavior: SnackBarBehavior.floating),
            );
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
