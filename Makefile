# HermesConsole Makefile
# Common development tasks

.PHONY: help
help: ## Show this help message
	@echo "HermesConsole - Development Commands"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: setup
setup: ## Install dependencies
	flutter pub get

.PHONY: run
run: ## Run the app in debug mode
	flutter run

.PHONY: run-profile
run-profile: ## Run the app in profile mode (performance testing)
	flutter run --profile

.PHONY: run-release
run-release: ## Run the app in release mode
	flutter run --release

.PHONY: analyze
analyze: ## Run static analysis
	flutter analyze

.PHONY: format
format: ## Format all Dart files
	dart format lib/ test/

.PHONY: format-check
format-check: ## Check formatting without changing files
	dart format --output=none --set-exit-if-changed lib/ test/

.PHONY: test
test: ## Run all unit tests
	flutter test

.PHONY: test-coverage
test-coverage: ## Run tests with coverage report
	flutter test --coverage
	@echo "Coverage report generated at coverage/lcov.info"

.PHONY: test-integration
test-integration: ## Run integration tests
	flutter test integration_test/

.PHONY: build-apk
build-apk: ## Build Android APK (release)
	flutter build apk --release

.PHONY: build-appbundle
build-appbundle: ## Build Android App Bundle (release)
	flutter build appbundle --release

.PHONY: build-ios
build-ios: ## Build iOS (release, no codesign)
	flutter build ios --release --no-codesign

.PHONY: build-web
build-web: ## Build Web (release)
	flutter build web --release

.PHONY: clean
clean: ## Clean build artifacts
	flutter clean
	rm -rf coverage/

.PHONY: deep-clean
deep-clean: clean ## Deep clean including pub cache
	flutter pub cache clean

.PHONY: gen
gen: ## Run code generation (build_runner)
	dart run build_runner build --delete-conflicting-outputs

.PHONY: gen-watch
gen-watch: ## Run code generation in watch mode
	dart run build_runner watch --delete-conflicting-outputs

.PHONY: l10n
l10n: ## Generate localization files
	flutter gen-l10n

.PHONY: check
check: format-check analyze test ## Run all checks (format, analyze, test)
	@echo "All checks passed!"

.PHONY: doctor
doctor: ## Run Flutter doctor
	flutter doctor -v

.PHONY: outdated
outdated: ## Check for outdated dependencies
	flutter pub outdated

.PHONY: upgrade
upgrade: ## Upgrade dependencies
	flutter pub upgrade
