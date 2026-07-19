#!/usr/bin/env bash
#
# hermes-console 本地开发环境初始化脚本
# 用法: ./setup.sh
#
set -euo pipefail

# 若已安装 FVM，则优先使用 `fvm flutter`，否则回退到系统 `flutter`
FLUTTER_CMD="flutter"
if command -v fvm >/dev/null 2>&1; then
  FLUTTER_CMD="fvm flutter"
  echo "检测到 FVM，将使用: fvm flutter"
fi

echo "==> 拉取依赖"
$FLUTTER_CMD pub get

echo "==> 静态分析（不阻断）"
$FLUTTER_CMD analyze --no-fatal-infos --no-fatal-warnings || true

echo ""
echo "✔ 初始化完成。"
echo "  • 启动应用: $FLUTTER_CMD run"
echo "  • 运行测试: $FLUTTER_CMD test"
echo "  • 构建 APK: $FLUTTER_CMD build apk --release"
echo ""
echo "⚠ 首次运行前，请将 assets/fonts/ 下的 JetBrainsMono 字体占位文件替换为真实字体:"
echo "   https://www.jetbrains.com/lp/mono/"
