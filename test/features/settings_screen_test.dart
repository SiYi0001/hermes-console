import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermes_console/features/settings/settings_screen.dart';
import 'package:hermes_console/shared/theme/hermes_theme.dart';

void main() {
  group('SettingsScreen — Widget Tests', () {
    testWidgets('renders all setting sections', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: HermesTheme.lightTheme,
            darkTheme: HermesTheme.darkTheme,
            themeMode: ThemeMode.dark,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 验证主要分段存在
      expect(find.text('加密与压缩'), findsOneWidget);
      expect(find.text('网络设置'), findsOneWidget);
      expect(find.text('外观'), findsOneWidget);
    });

    testWidgets('dark mode toggle is present', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: HermesTheme.darkTheme,
            themeMode: ThemeMode.dark,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch 控件存在
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('can scroll through settings', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: HermesTheme.darkTheme,
            themeMode: ThemeMode.dark,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 尝试滚动到页面底部
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // 危险操作区域（Danger Zone）
      expect(find.text('危险操作'), findsOneWidget);
    });

    testWidgets('app version info is displayed', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: HermesTheme.darkTheme,
            themeMode: ThemeMode.dark,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 版本信息显示（向下滚动到最底部）
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1000));
      await tester.pumpAndSettle();

      // 版本号通常包含 "v" 或数字
      expect(find.byType(AboutListTile), findsWidgets);
    });
  });
}
