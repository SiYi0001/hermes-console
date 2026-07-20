import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/network/p2p_data_channel.dart';
import '../../core/storage/hive_init.dart';
import '../../shared/theme/hermes_theme.dart';

class ConnectScreen extends ConsumerStatefulWidget {
  const ConnectScreen({super.key});

  @override
  ConsumerState<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends ConsumerState<ConnectScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _peerIdController = TextEditingController();
  final _addressController = TextEditingController();
  final _portController = TextEditingController(text: '8080');

  bool _showQrScanner = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _peerIdController.dispose();
    _addressController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HermesTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: HermesTheme.backgroundBlack,
        title: const Text('Connect'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: HermesTheme.primaryBlue,
          labelColor: HermesTheme.primaryBlue,
          unselectedLabelColor: HermesTheme.textSecondary,
          tabs: const [
            Tab(text: 'Scan', icon: Icon(Icons.qr_code_scanner, size: 20)),
            Tab(text: 'Manual', icon: Icon(Icons.keyboard, size: 20)),
            Tab(text: 'QR Code', icon: Icon(Icons.qr_code, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScanTab(),
          _buildManualTab(),
          _buildQrCodeTab(),
        ],
      ),
    );
  }

  Widget _buildScanTab() {
    if (_showQrScanner) {
      return Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleQrCode(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: HermesTheme.surfaceDark.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: HermesTheme.primaryBlue, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Point camera at QR code',
                            style: TextStyle(
                                color: HermesTheme.textSecondary, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _showQrScanner = false),
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HermesTheme.surfaceDark,
                      minimumSize: const Size(200, 48),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: HermesTheme.surfaceDark,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: HermesTheme.primaryBlue.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: HermesTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Scan QR Code',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Scan the QR code displayed on the\nHermes Agent device',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: HermesTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => setState(() => _showQrScanner = true),
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('Open Camera Scanner'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _showManualEntry,
              icon: const Icon(Icons.keyboard_rounded),
              label: const Text('Enter Manually'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                side: const BorderSide(color: HermesTheme.textSecondary),
                foregroundColor: HermesTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showManualEntry() {
    _tabController.animateTo(1);
  }

  Widget _buildManualTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Peer ID Input
            const Text(
              'Peer ID',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: HermesTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _peerIdController,
              decoration: const InputDecoration(
                hintText: 'Enter peer ID (e.g., abc123...)',
                prefixIcon: Icon(Icons.tag, color: HermesTheme.textSecondary),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),

            // Advanced Options
            ExpansionTile(
              title: const Text(
                'Advanced Options',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: HermesTheme.textSecondary,
                ),
              ),
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Direct Address (optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: HermesTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    hintText: 'IP or hostname',
                    prefixIcon: Icon(Icons.language, color: HermesTheme.textSecondary),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _portController,
                  decoration: const InputDecoration(
                    hintText: 'Port',
                    prefixIcon: Icon(Icons.settings_ethernet, color: HermesTheme.textSecondary),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Connect Button
            ElevatedButton.icon(
              onPressed: _connect,
              icon: const Icon(Icons.link_rounded),
              label: const Text('Connect'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: HermesTheme.successGreen,
              ),
            ),
            const SizedBox(height: 16),

            // Security Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: HermesTheme.surfaceDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: HermesTheme.successGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: HermesTheme.successGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End-to-End Encrypted',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'AES-256-GCM + Curve25519',
                          style: TextStyle(
                            fontSize: 12,
                            color: HermesTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrCodeTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: HermesTheme.primaryBlue.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: QrImageView(
                data: 'hermes://connect/${DateTime.now().millisecondsSinceEpoch}',
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Your Connection ID',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: HermesTheme.surfaceDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'hermes-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                    style: HermesTheme.codeStyle,
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(
                        text: 'hermes-peer-id-example',
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.copy_rounded,
                      color: HermesTheme.primaryBlue,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            const Text(
              'Share this code with others to let them connect to your session',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: HermesTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _handleQrCode(String data) {
    setState(() => _showQrScanner = false);
    _peerIdController.text = data;
    _tabController.animateTo(1);
  }

  void _connect() {
    final peerId = _peerIdController.text.trim();
    if (peerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a peer ID'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Save session
    final session = SessionData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Session ${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      peerId: peerId,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    SessionStorage.saveSession(session);

    // Kick off the real connection lifecycle (connecting -> connected + heartbeat)
    ref.read(connectionStateProvider.notifier).connect(
          peerId,
          peerName: session.name,
        );

    // Show success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connecting to $peerId...'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: HermesTheme.primaryBlue,
      ),
    );
  }
}
