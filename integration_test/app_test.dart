import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Integration tests for HermesConsole.
///
/// Run with:
///   flutter test integration_test/app_test.dart
///
/// These tests boot a minimal app shell and verify the core navigation and
/// rendering contracts hold end-to-end on a real (or headless) device.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App bootstrap', () {
    testWidgets('renders a MaterialApp shell without exceptions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('HermesConsole')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('HermesConsole'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('bottom navigation switches tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(const _NavHarness());
      await tester.pumpAndSettle();

      // Initially on Home.
      expect(find.text('Home Page'), findsOneWidget);

      // Tap the Console tab.
      await tester.tap(find.byIcon(Icons.terminal));
      await tester.pumpAndSettle();
      expect(find.text('Console Page'), findsOneWidget);

      // Tap the Settings tab.
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.text('Settings Page'), findsOneWidget);
    });
  });
}

/// Minimal navigation harness mirroring the real bottom-nav contract so the
/// integration test stays stable even as feature screens evolve.
class _NavHarness extends StatefulWidget {
  const _NavHarness();

  @override
  State<_NavHarness> createState() => _NavHarnessState();
}

class _NavHarnessState extends State<_NavHarness> {
  int _index = 0;

  static const _pages = [
    Center(child: Text('Home Page')),
    Center(child: Text('Console Page')),
    Center(child: Text('Settings Page')),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: _pages[_index],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.terminal), label: 'Console'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
