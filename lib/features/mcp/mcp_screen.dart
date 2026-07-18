import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _McpServersTab(),
                _BuiltInToolsTab(),
                _ToolLogsTab(),
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
      builder: (context) => const _AddMcpServerDialog(),
    );
  }
}

/// MCP Servers Tab
class _McpServersTab extends StatelessWidget {
  const _McpServersTab();

  @override
  Widget build(BuildContext context) {
    final servers = [
      _McpServer(
        id: '1',
        name: 'File System',
        type: 'Local',
        status: 'active',
        toolsCount: 12,
        lastUsed: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      _McpServer(
        id: '2',
        name: 'GitHub API',
        type: 'Remote',
        status: 'active',
        toolsCount: 8,
        lastUsed: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      _McpServer(
        id: '3',
        name: 'Database',
        type: 'Local',
        status: 'active',
        toolsCount: 6,
        lastUsed: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      _McpServer(
        id: '4',
        name: 'Browser Automation',
        type: 'Remote',
        status: 'inactive',
        toolsCount: 15,
        lastUsed: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: servers.length,
      itemBuilder: (context, index) {
        return _McpServerCard(server: servers[index]);
      },
    );
  }
}

class _McpServerCard extends StatelessWidget {
  final _McpServer server;

  const _McpServerCard({required this.server});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: server.status == 'active'
            ? Border.all(color: HermesTheme.successGreen.withOpacity(0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (server.type == 'Local'
                          ? HermesTheme.primaryBlue
                          : HermesTheme.secondaryPurple)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  server.type == 'Local'
                      ? Icons.computer
                      : Icons.cloud_outlined,
                  color: server.type == 'Local'
                      ? HermesTheme.primaryBlue
                      : HermesTheme.secondaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      server.name,
                      style: const TextStyle(
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
                            color: server.type == 'Local'
                                ? HermesTheme.primaryBlue.withOpacity(0.15)
                                : HermesTheme.secondaryPurple.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            server.type,
                            style: TextStyle(
                              fontSize: 10,
                              color: server.type == 'Local'
                                  ? HermesTheme.primaryBlue
                                  : HermesTheme.secondaryPurple,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: server.status == 'active'
                                ? HermesTheme.successGreen
                                : HermesTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          server.status,
                          style: TextStyle(
                            fontSize: 11,
                            color: server.status == 'active'
                                ? HermesTheme.successGreen
                                : HermesTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: HermesTheme.textSecondary,
                ),
                color: HermesTheme.surfaceElevated,
                onSelected: (value) {
                  // Handle menu actions
                },
                itemBuilder: (context) => [
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
                    value: 'restart',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, size: 18),
                        SizedBox(width: 8),
                        Text('Restart'),
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.extension,
                    size: 14,
                    color: HermesTheme.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${server.toolsCount} tools',
                    style: const TextStyle(
                      fontSize: 12,
                      color: HermesTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: HermesTheme.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Last used: ${_formatTime(server.lastUsed)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: HermesTheme.textSecondary,
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

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

/// Built-in Tools Tab
class _BuiltInToolsTab extends StatelessWidget {
  const _BuiltInToolsTab();

  @override
  Widget build(BuildContext context) {
    final tools = [
      _ToolItem(
        name: 'terminal',
        description: 'Execute shell commands',
        category: 'System',
        enabled: true,
        usageCount: 156,
      ),
      _ToolItem(
        name: 'read_file',
        description: 'Read file contents',
        category: 'File',
        enabled: true,
        usageCount: 234,
      ),
      _ToolItem(
        name: 'write_file',
        description: 'Create or update files',
        category: 'File',
        enabled: true,
        usageCount: 89,
      ),
      _ToolItem(
        name: 'web_search',
        description: 'Search the web',
        category: 'Network',
        enabled: true,
        usageCount: 67,
      ),
      _ToolItem(
        name: 'browser',
        description: 'Control browser automation',
        category: 'Automation',
        enabled: false,
        usageCount: 12,
      ),
      _ToolItem(
        name: 'screenshot',
        description: 'Take screenshots',
        category: 'Media',
        enabled: true,
        usageCount: 45,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        return _ToolCard(tool: tools[index]);
      },
    );
  }
}

class _ToolCard extends StatelessWidget {
  final _ToolItem tool;

  const _ToolCard({required this.tool});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        value: tool.enabled,
        onChanged: (value) {},
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getCategoryColor(tool.category).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCategoryIcon(tool.category),
            color: tool.enabled
                ? _getCategoryColor(tool.category)
                : HermesTheme.textSecondary,
            size: 20,
          ),
        ),
        title: Text(
          tool.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: tool.enabled ? Colors.white : HermesTheme.textSecondary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tool.description,
              style: const TextStyle(
                fontSize: 12,
                color: HermesTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: HermesTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tool.category,
                    style: const TextStyle(
                      fontSize: 10,
                      color: HermesTheme.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${tool.usageCount} uses',
                  style: const TextStyle(
                    fontSize: 10,
                    color: HermesTheme.textTertiary,
                  ),
                ),
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
  const _ToolLogsTab();

  @override
  Widget build(BuildContext context) {
    final logs = [
      _ToolLog(
        tool: 'terminal',
        command: 'flutter build apk --debug',
        status: 'success',
        duration: '2.3s',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      _ToolLog(
        tool: 'read_file',
        command: 'lib/main.dart',
        status: 'success',
        duration: '45ms',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      _ToolLog(
        tool: 'web_search',
        command: 'Flutter best practices 2024',
        status: 'success',
        duration: '1.2s',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      _ToolLog(
        tool: 'write_file',
        command: 'output.json',
        status: 'error',
        duration: '120ms',
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        return _ToolLogCard(log: logs[index]);
      },
    );
  }
}

class _ToolLogCard extends StatelessWidget {
  final _ToolLog log;

  const _ToolLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: log.status == 'error'
            ? Border.all(color: HermesTheme.errorRed.withOpacity(0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: HermesTheme.primaryBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  log.tool,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: HermesTheme.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                log.status == 'success'
                    ? Icons.check_circle
                    : Icons.error,
                size: 14,
                color: log.status == 'success'
                    ? HermesTheme.successGreen
                    : HermesTheme.errorRed,
              ),
              const Spacer(),
              Text(
                log.duration,
                style: const TextStyle(
                  fontSize: 11,
                  color: HermesTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatTime(log.timestamp),
                style: const TextStyle(
                  fontSize: 11,
                  color: HermesTheme.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            log.command,
            style: HermesTheme.codeStyle.copyWith(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

/// Add MCP Server Dialog
class _AddMcpServerDialog extends StatefulWidget {
  const _AddMcpServerDialog();

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
              decoration: const InputDecoration(
                labelText: 'Server Name',
                hintText: 'e.g., GitHub API',
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Server Type',
              style: TextStyle(
                fontSize: 14,
                color: HermesTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Local'),
                  selected: _serverType == 'local',
                  onSelected: (selected) {
                    if (selected) setState(() => _serverType = 'local');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Remote'),
                  selected: _serverType == 'remote',
                  onSelected: (selected) {
                    if (selected) setState(() => _serverType = 'remote');
                  },
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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('MCP Server added successfully'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// Models
class _McpServer {
  final String id;
  final String name;
  final String type;
  final String status;
  final int toolsCount;
  final DateTime lastUsed;

  _McpServer({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.toolsCount,
    required this.lastUsed,
  });
}

class _ToolItem {
  final String name;
  final String description;
  final String category;
  final bool enabled;
  final int usageCount;

  _ToolItem({
    required this.name,
    required this.description,
    required this.category,
    required this.enabled,
    required this.usageCount,
  });
}

class _ToolLog {
  final String tool;
  final String command;
  final String status;
  final String duration;
  final DateTime timestamp;

  _ToolLog({
    required this.tool,
    required this.command,
    required this.status,
    required this.duration,
    required this.timestamp,
  });
}
