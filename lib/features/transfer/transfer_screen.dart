import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
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
    final transfers = ref.watch(appStateProvider).transfers;
    final files = ref.watch(appStateProvider).sharedFiles;
    final notifier = ref.read(appStateProvider.notifier);

    return Scaffold(
      backgroundColor: HermesTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: HermesTheme.backgroundBlack,
        title: const Text('File Transfer'),
        actions: [
          IconButton(onPressed: () => _refresh(notifier), icon: const Icon(Icons.refresh)),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: HermesTheme.primaryBlue,
          labelColor: HermesTheme.primaryBlue,
          unselectedLabelColor: HermesTheme.textSecondary,
          tabs: const [Tab(text: 'Transfers'), Tab(text: 'Shared Files')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TransfersTab(transfers: transfers, notifier: notifier),
          _SharedFilesTab(files: files, notifier: notifier),
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

  void _refresh(AppStateNotifier notifier) {
    notifier.addToolLog(ToolLog(tool: 'transfer', command: 'refresh', status: 'success', duration: '0ms', timestamp: DateTime.now()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transfers refreshed'), behavior: SnackBarBehavior.floating),
    );
  }

  void _showNewTransferDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: HermesTheme.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _NewTransferSheet(
        onAdd: (name, peer) {
          ref.read(appStateProvider.notifier).addTransfer(
                FileTransfer.create(name: name, sizeBytes: 1024 * 1024, peer: peer),
              );
        },
      ),
    );
  }
}

/// Transfers Tab
class _TransfersTab extends StatelessWidget {
  final List<FileTransfer> transfers;
  final AppStateNotifier notifier;
  const _TransfersTab({required this.transfers, required this.notifier});

  @override
  Widget build(BuildContext context) {
    if (transfers.isEmpty) {
      return const Center(child: Text('No transfers yet.', style: TextStyle(color: HermesTheme.textSecondary)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transfers.length,
      itemBuilder: (context, index) => _TransferCard(transfer: transfers[index], notifier: notifier),
    );
  }
}

class _TransferCard extends StatelessWidget {
  final FileTransfer transfer;
  final AppStateNotifier notifier;
  const _TransferCard({required this.transfer, required this.notifier});

  bool get _isUpload => transfer.status != 'completed';

  @override
  Widget build(BuildContext context) {
    final color = transfer.status == 'completed'
        ? HermesTheme.successGreen
        : _isUpload
            ? HermesTheme.warningAmber
            : HermesTheme.successGreen;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HermesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: transfer.status == 'failed'
            ? Border.all(color: HermesTheme.errorRed.withValues(alpha: 0.3))
            : transfer.status == 'completed'
                ? Border.all(color: HermesTheme.successGreen.withValues(alpha: 0.3))
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(_isUpload ? Icons.upload_file : Icons.download, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transfer.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(NetworkUtils.formatBytes(transfer.sizeBytes), style: const TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
                        const SizedBox(width: 8),
                        const Icon(Icons.people_alt, size: 12, color: HermesTheme.textTertiary),
                        const SizedBox(width: 4),
                        Text(transfer.peer, style: const TextStyle(fontSize: 12, color: HermesTheme.textTertiary)),
                      ],
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: transfer.status),
            ],
          ),
          if (transfer.status == 'transferring' || transfer.status == 'pending') ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: transfer.progress,
                backgroundColor: HermesTheme.surfaceElevated,
                valueColor: const AlwaysStoppedAnimation<Color>(HermesTheme.primaryBlue),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(transfer.progress * 100).toInt()}%', style: const TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => notifier.updateTransfer(transfer.id, status: 'canceled'),
                      icon: const Icon(Icons.close, size: 20, color: HermesTheme.errorRed),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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
                const Icon(Icons.error_outline, size: 14, color: HermesTheme.errorRed),
                const SizedBox(width: 6),
                const Text('Connection lost', style: TextStyle(fontSize: 12, color: HermesTheme.errorRed)),
                const Spacer(),
                TextButton(
                  onPressed: () => notifier.updateTransfer(transfer.id, status: 'transferring', progress: 0),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
          if (transfer.status != 'transferring' && transfer.status != 'pending' && transfer.status != 'failed') ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => notifier.removeTransfer(transfer.id),
                child: const Text('Remove'),
              ),
            ),
          ],
        ],
      ),
    );
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
      case 'canceled':
        color = HermesTheme.textSecondary;
        text = 'Canceled';
        icon = Icons.cancel;
        break;
      default:
        color = HermesTheme.textSecondary;
        text = 'Pending';
        icon = Icons.schedule;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

/// Shared Files Tab
class _SharedFilesTab extends StatelessWidget {
  final List<SharedFile> files;
  final AppStateNotifier notifier;
  const _SharedFilesTab({required this.files, required this.notifier});

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return const Center(child: Text('No shared files yet.', style: TextStyle(color: HermesTheme.textSecondary)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: files.length,
      itemBuilder: (context, index) => _SharedFileCard(file: files[index], notifier: notifier),
    );
  }
}

class _SharedFileCard extends StatelessWidget {
  final SharedFile file;
  final AppStateNotifier notifier;
  const _SharedFileCard({required this.file, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final isImage = file.name.endsWith('.png') || file.name.endsWith('.jpg') || file.name.endsWith('.mp4');
    final color = isImage ? HermesTheme.successGreen : HermesTheme.primaryBlue;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: HermesTheme.surfaceDark, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
          child: Icon(isImage ? Icons.image : Icons.description, color: color, size: 20),
        ),
        title: Text(file.name, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white)),
        subtitle: Text('${NetworkUtils.formatBytes(file.sizeBytes)} • ${file.sharedAt.relativeTime}',
            style: const TextStyle(fontSize: 12, color: HermesTheme.textSecondary)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: HermesTheme.textSecondary),
          onPressed: () => notifier.removeSharedFile(file.id),
        ),
      ),
    );
  }
}

/// New Transfer Sheet
class _NewTransferSheet extends StatefulWidget {
  final void Function(String name, String peer) onAdd;
  const _NewTransferSheet({required this.onAdd});

  @override
  State<_NewTransferSheet> createState() => _NewTransferSheetState();
}

class _NewTransferSheetState extends State<_NewTransferSheet> {
  String _transferType = 'file';
  final _nameController = TextEditingController(text: 'document.pdf');
  final _peerController = TextEditingController(text: 'node-7f3a');

  @override
  void dispose() {
    _nameController.dispose();
    _peerController.dispose();
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
          const Text('New Transfer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          Row(
            children: [
              ChoiceChip(label: const Text('File'), selected: _transferType == 'file', onSelected: (s) => s ? setState(() => _transferType = 'file') : null),
              const SizedBox(width: 8),
              ChoiceChip(label: const Text('Folder'), selected: _transferType == 'folder', onSelected: (s) => s ? setState(() => _transferType = 'folder') : null),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'File name', hintText: 'e.g., document.pdf'),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _peerController,
            decoration: const InputDecoration(labelText: 'Peer node id', hintText: 'e.g., node-7f3a'),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final name = _nameController.text.trim();
                    final peer = _peerController.text.trim();
                    if (name.isEmpty || peer.isEmpty) return;
                    widget.onAdd(name, peer);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transfer queued'), behavior: SnackBarBehavior.floating),
                    );
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
