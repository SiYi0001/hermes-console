# HermesConsole Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [2.4.1] - 2025-07-19

### Fixed
- **webRTC package name** — `webRTC` is not a valid Dart package name; the
  correct dependency is lowercase `webrtc`, keeping the existing
  `package:webrtc/models/*` import subpaths (the real cause behind the missing
  `flutter_webrtc`/package-not-found errors).
- **Settings screen now wired to real state** — removed all mock local state;
  every toggle writes through `SettingsNotifier` and persists to Hive.
- **Live dark/light theme** — `HermesConsoleApp` reads `themeModeProvider` so the
  Dark Mode toggle takes effect immediately (added `lightTheme` variant).
- **First-run onboarding routing** — `main.dart` now initializes Hive, injects
  `settingsBoxProvider`, and routes Splash -> Onboarding (first launch) -> Main.
- **Latent Hive bug** — `HiveInit` now opens the `hermes_key_store` box before
  reading the encryption key (previously would throw on real init).
- **Onboarding navigation context** — `OnboardingScreen` navigates from its own
  context via `nextScreenBuilder` instead of a captured (now-deactivated)
  parent `BuildContext`.

## [2.4.0] - 2025-07-19

### Added
- **Real settings persistence** (`core/services/settings_service.dart`)
  - `AppSettings` immutable model with full JSON round-trip
  - `SettingsNotifier` persists every mutation to Hive synchronously
  - Riverpod selectors (`themeModeProvider`, `localeCodeProvider`, `onboardingCompleteProvider`) for minimal rebuilds
- **Onboarding flow** (`features/onboarding/onboarding_screen.dart`)
  - 4-page first-run intro (P2P / encryption / performance / unified console)
  - Persists completion flag so it shows only once
- **Integration tests** (`integration_test/app_test.dart`)
  - App bootstrap + bottom-navigation contract tests
- **Settings unit tests** (`test/settings_service_test.dart`)
  - Serialization, defaults, copyWith, malformed-data fallback

### Repository / Tooling
- GitHub Pull Request template
- Dependabot config (pub / github-actions / gradle)
- Makefile with 25+ dev shortcuts
- Published to GitHub: https://github.com/SiYi0001/hermes-console

## [2.1.0] - 2025-07-15

### Added
- **Performance Optimizations**
  - Riverpod state management with selective rebuilds
  - Ring buffer for console output (max 1000 lines)
  - LRU cache (50 items)
  - Object pooling for reduced GC pressure
  - Debouncing and throttling utilities
  - Batched UI updates (50ms window)
  - RepaintBoundary isolation
  - AutomaticKeepAliveClientMixin for scroll preservation

- **Advanced Networking**
  - P2P connection manager with reconnection logic
  - Exponential backoff for retries
  - Circuit breaker pattern
  - Network quality assessment
  - Connection profile adaptation

- **Error Handling & Recovery**
  - Global error handler with logging
  - Circuit breaker for fault tolerance
  - Graceful degradation handler
  - Retry strategies
  - Result type for functional error handling

- **Internationalization**
  - English (en) and Chinese (zh) locales
  - ARB files for localization
  - AppLocalizations class
  - Locale provider

- **Accessibility**
  - Screen reader support
  - High contrast mode detection
  - Reduced motion utilities
  - Keyboard navigation helpers
  - Live regions for dynamic content
  - Large tap targets

### Fixed
- Memory leak in console output
- Race conditions in connection state
- Improper resource disposal

## [2.0.0] - 2025-07-14

### Added
- **Feature Screens**
  - Dashboard with connection status and quick actions
  - Connect screen with QR code support
  - Console with terminal emulation
  - Status monitoring screen
  - Settings screen
  - Memory management
  - MCP tools management
  - Cron automation
  - Logs viewer
  - Gateway integration
  - File transfer
  - Notifications
  - Profile management
  - Performance monitoring

- **Core Infrastructure**
  - AES-256-GCM encryption
  - WebRTC P2P DataChannel
  - Zstd compression
  - Hive local storage
  - QClaw-inspired dark theme

## [1.0.0] - 2025-07-13

### Added
- Initial project structure
- P2P protocol specification
- Basic navigation
