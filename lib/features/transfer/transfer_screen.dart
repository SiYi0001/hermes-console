import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme/hermes_theme.dart';

/// File Transfer Screen
class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('File Transfer'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: HermesTheme.primaryBlue,
          labelColor: HermesTheme.primaryBlue,
          unselectedLabelColor: HermesTheme.textSecondary,
          tabs: const [
            Tab(text: 'Transfers'),
            Tab(text: 'Shared Files'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TransfersTab(),
          _SharedFilesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewTransferDialog,
        backgroundColor: HermesTheme.primaryBlue,
        icon: const Icon(Icons.add),
        label: const Text('New Transfer'),
      ),
    );
  }

  void _refresh() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing transfers...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showNewTransferDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesTheme.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _NewTransferSheet(),
    );
  }
}

/// Transfers Tab
class _TransfersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final transfers = [
      _Transfer(
        id: '1',
        fileName: 'project_backup.zip',
        size: '45.2 MB',
        progress: 0.78,
        status: 'transferring',
        speed: '2.3 MB/s',
        direction: 'upload',
      ),
      _Transfer(
        id: '2',
        fileName: 'code_review.md',
        size: '128 KB',
        progress: 1.0,
        status: 'completed',
        speed: '',
        direction: 'download',
      ),
      _Transfer(
        id: '3',
        fileName: 'database_dump.sql',
        size: '12.5 MB',
        progress: 1.0,
        status: 'completed',
        speed: '',
        direction: 'download',
      ),
      _Transfer(
        id: '4',
        fileName: 'config.yaml',
        size: '4 KB',
        progress: 1.0,
        status: 'failed',
        speed: '',
        direction: 'upload',
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transfers.length,
      itemBuilder: (context, index) {
        return _TransferCard(transfer: transfers[index]);
      },
    );
  }
}

class _TransferCard extends StatelessWidget {
  final _Transfer transfer;

  const _TransferCard({required this.transfer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: transfer.status == 'failed'
            ? Border.all(color: HermesTheme.errorRed.withOpacity(0.3))
            : transfer.status == 'completed'
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
                  color: _getDirectionColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  transfer.direction == 'upload'
                      ? Icons.upload_file
                      : Icons.download,
                  color: _getDirectionColor(),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transfer.fileName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          transfer.size,
                          style: const TextStyle(
                            fontSize: 12,
                            color: HermesTheme.textSecondary,
                          ),
                        ),
                        if (transfer.speed.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.speed,
                            size: 12,
                            color: HermesTheme.primaryBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            transfer.speed,
                            style: const TextStyle(
                              fontSize: 12,
                              color: HermesTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: transfer.status),
            ],
          ),
          if (transfer.status == 'transferring') ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: transfer.progress,
                backgroundColor: HermesTheme.surfaceElevated,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  HermesTheme.primaryBlue,
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(transfer.progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: HermesTheme.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.pause, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: HermesTheme.errorRed,
                    ),
                  ],
                ),
              ],
            ),
          ],
          if (transfer.status == 'failed') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 14,
                  color: HermesTheme.errorRed,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Connection lost',
                  style: TextStyle(
                    fontSize: 12,
                    color: HermesTheme.errorRed,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getDirectionColor() {
    return transfer.direction == 'upload'
        ? HermesTheme.warningAmber
        : HermesTheme.successGreen;
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'completed':
        color = HermesTheme.successGreen;
        text = 'Done';
        icon = Icons.check_circle;
        break;
      case 'transferring':
        color = HermesTheme.primaryBlue;
        text = 'Transferring';
        icon = Icons.sync;
        break;
      case 'failed':
        color = HermesTheme.errorRed;
        text = 'Failed';
        icon = Icons.error;
        break;
      default:
        color = HermesTheme.textSecondary;
        text = 'Pending';
        icon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared Files Tab
class _SharedFilesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final files = [
      _SharedFile(
        name: 'project_docs',
        type: 'folder',
        size: '128 MB',
        modified: DateTime.now().subtract(const Duration(days: 1)),
      ),
      _SharedFile(
        name: 'api_spec.json',
        type: 'json',
        size: '24 KB',
        modified: DateTime.now().subtract(const Duration(days: 2)),
      ),
      _SharedFile(
        name: 'screenshot.png',
        type: 'image',
        size: '1.2 MB',
        modified: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      _SharedFile(
        name: 'notes.md',
        type: 'text',
        size: '8 KB',
        modified: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: files.length,
      itemBuilder: (context, index) {
        return _SharedFileCard(file: files[index]);
      },
    );
  }
}

class _SharedFileCard extends StatelessWidget {
  final _SharedFile file;

  const _SharedFileCard({required this.file});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getTypeColor().withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTypeIcon(),
            color: _getTypeColor(),
            size: 20,
          ),
        ),
        title: Text(
          file.name,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          '${file.size} • ${_formatDate(file.modified)}',
          style: const TextStyle(
            fontSize: 12,
            color: HermesTheme.textSecondary,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: HermesTheme.textSecondary),
          onPressed: () {},
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (file.type) {
      case 'folder':
        return HermesTheme.warningAmber;
      case 'json':
        return HermesTheme.warningAmber;
      case 'image':
        return HermesTheme.successGreen;
      case 'text':
        return HermesTheme.primaryBlue;
      default:
        return HermesTheme.textSecondary;
    }
  }

  IconData _getTypeIcon() {
    switch (file.type) {
      case 'folder':
        return Icons.folder;
      case 'json':
        return Icons.data_object;
      case 'image':
        return Icons.image;
      case 'text':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}

/// New Transfer Sheet
class _NewTransferSheet extends StatefulWidget {
  const _NewTransferSheet();

  @override
  State<_NewTransferSheet> createState() => _NewTransferSheetState();
}

class _NewTransferSheetState extends State<_NewTransferSheet> {
  String _transferType = 'file';

  @override
  Widget build(BuildContext context) {
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
              decoration: BoxDecoration(
                color: HermesTheme.surfaceOverlay,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'New Transfer',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ChoiceChip(
                label: const Text('File'),
                selected: _transferType == 'file',
                onSelected: (selected) {
                  if (selected) setState(() => _transferType = 'file');
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Folder'),
                selected: _transferType == 'folder',
                onSelected: (selected) {
                  if (selected) setState(() => _transferType = 'folder');
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: HermesTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: HermesTheme.primaryBlue.withOpacity(0.3),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _transferType == 'file'
                      ? Icons.upload_file
                      : Icons.folder,
                  size: 48,
                  color: HermesTheme.primaryBlue,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Click to select files',
                  style: TextStyle(
                    color: HermesTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _transferType == 'file'
                      ? 'Any file type supported'
                      : 'All files in folder',
                  style: const TextStyle(
                    fontSize: 12,
                    color: HermesTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Start Transfer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Models
class _Transfer {
  final String id;
  final String fileName;
  final String size;
  final double progress;
  final String status;
  final String speed;
  final String direction;

  _Transfer({
    required this.id,
    required this.fileName,
    required this.size,
    required this.progress,
    required this.status,
    required this.speed,
    required this.direction,
  });
}

class _SharedFile {
  final String name;
  final String type;
  final String size;
  final DateTime modified;

  _SharedFile({
    required this.name,
    required this.type,
    required this.size,
    required this.modified,
  });
}
