# HermesConsole Makefile
# 提供常用命令快捷方式
#
# 用法:
#   make help        显示所有可用命令
#   make analyze     运行静态分析
#   make test        运行测试
#   make build       构建所有平台
#   make clean       清理构建产物

.PHONY: help analyze test test-coverage build build-apk build-ios build-web \
        clean lint format run-android run-ios pub-get pub-upgrade \
        release-apk release-ios

# 默认目标：显示帮助
.DEFAULT_GOAL := help

# Flutter 命令（使用 FVM 时可在调用前 export FLUTTER="fvm flutter"）
FLUTTER ?= flutter

## ──────────────────────────────────────────
# 开发命令
## ──────────────────────────────────────────

help: ## 显示帮助信息 / Show this help
	@echo ""
	@echo "HermesConsole Makefile — 可用命令"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "示例 / Examples:"
	@echo "  make analyze       # 运行静态分析"
	@echo "  make test         # 运行测试"
	@echo "  make build-apk     # 构建 Android APK"
	@echo ""

pub-get: ## 安装依赖 / Install dependencies
$(FLUTTER) pub get

pub-upgrade: ## 升级依赖 / Upgrade dependencies
$(FLUTTER) pub upgrade

## ──────────────────────────────────────────
# 代码质量
## ──────────────────────────────────────────

analyze: ## 静态分析 / Run Flutter analyze
$(FLUTTER) analyze --no-fatal-infos --no-fatal-warnings

lint: ## 运行 lint / Run linter
$(FLUTTER) analyze

format: ## 格式化代码 / Format code
$(FLUTTER) format lib/ test/

test: ## 运行单元测试 / Run unit tests
$(FLUTTER) test --no-pub

test-coverage: ## 运行测试并生成覆盖率 / Run tests with coverage
$(FLUTTER) test --no-pub --coverage
	genhtml coverage/lcov.info -o coverage/html
	@echo "覆盖率报告: coverage/html/index.html"

## ──────────────────────────────────────────
# 构建
## ──────────────────────────────────────────

build: build-apk build-ios build-web ## 构建所有平台 / Build all platforms

build-apk: ## 构建 Android APK / Build Android debug APK
$(FLUTTER) build apk --debug

build-web: ## 构建 Web / Build Web app
$(FLUTTER) build web

run-android: ## 在 Android 设备/模拟器运行 / Run on Android
$(FLUTTER) run -d android

run-ios: ## 在 iOS 模拟器运行 / Run on iOS simulator
$(FLUTTER) run -d iphone

## ──────────────────────────────────────────
# 发布构建
## ──────────────────────────────────────────

release-apk: ## 构建 Android Release APK / Build Android release APK
$(FLUTTER) build apk --release --obfuscate --split-debug-info=build/debug-info

release-ios: ## 构建 iOS Release / Build iOS release
$(FLUTTER) build ios --release

## ──────────────────────────────────────────
# 清理
## ──────────────────────────────────────────

clean: ## 清理构建产物 / Clean build artifacts
$(FLUTTER) clean
	rm -rf coverage/
	rm -rf build/
	rm -f .dart_tool/package_config.json
