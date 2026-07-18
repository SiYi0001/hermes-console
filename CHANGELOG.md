# HermesConsole Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

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
