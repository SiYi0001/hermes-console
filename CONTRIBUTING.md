# Contributing to HermesConsole

Thank you for your interest in contributing to HermesConsole! This document provides guidelines and instructions for contributing.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)

## Code of Conduct

By participating in this project, you agree to maintain a welcoming and respectful environment for everyone. Please read our [Code of Conduct](CODE_OF_CONDUCT.md) before contributing.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/hermes-console.git
   cd hermes-console
   ```
3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/hermes-console/hermes-console.git
   ```

## Development Setup

### Prerequisites

- Flutter SDK 3.3.0 or higher
- Dart 3.3.0 or higher
- Android SDK (for Android development)
- Xcode (for iOS/macOS development)

### Installation

```bash
# Install Flutter dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze
```

### Environment Variables

Create a `.env` file in the project root:

```env
# Optional: API keys for development
STUN_SERVER=stun:stun.l.google.com:19302
TURN_SERVER=your-turn-server
```

## Making Changes

### 1. Create a Branch

```bash
# Fetch latest changes
git fetch upstream

# Create a feature branch
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

### 2. Branch Naming Convention

- `feature/` - New features
- `fix/` - Bug fixes
- `refactor/` - Code refactoring
- `docs/` - Documentation changes
- `test/` - Test additions/changes
- `perf/` - Performance improvements

### 3. Make Your Changes

- Write clean, maintainable code
- Follow the coding standards
- Add tests for new functionality
- Update documentation as needed

### 4. Commit Your Changes

```bash
git add .
git commit -m "feat: add new feature description"
```

#### Commit Message Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code style changes (formatting, semicolons, etc)
- `refactor` - Code refactoring
- `perf` - Performance improvements
- `test` - Adding or updating tests
- `chore` - Maintenance tasks

**Examples:**
```
feat(network): add P2P reconnection logic
fix(console): resolve memory leak in ring buffer
docs(readme): update installation instructions
refactor(crypto): simplify key exchange flow
perf(ui): optimize list rendering with RepaintBoundary
test(error): add circuit breaker unit tests
```

## Pull Request Process

### Before Submitting

1. **Update your branch** with the latest from upstream:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run tests** to ensure everything passes:
   ```bash
   flutter test
   flutter analyze
   ```

3. **Check for linting issues**:
   ```bash
   flutter pub run dart_language_server -- analyze
   ```

### Submitting

1. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Open a Pull Request** against the `main` branch

3. **Fill out the PR template** with:
   - Description of changes
   - Related issue number (e.g., "Fixes #123")
   - Testing performed
   - Screenshots (for UI changes)

### PR Review Process

- Reviews are typically done within 48 hours
- Address any feedback from reviewers
- Once approved, your PR will be merged

## Coding Standards

### Flutter/Dart

- Use `flutter analyze` for linting
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `const` constructors where possible
- Prefer composition over inheritance
- Keep functions small and focused

### Naming Conventions

```dart
// Classes: PascalCase
class ConnectionManager {}

// Methods: camelCase
void connectToPeer() {}

// Variables: camelCase
String peerId = '123';

// Constants: camelCase with k prefix
const int kMaxRetries = 5;

// Private members: leading underscore
String _privateField;
```

### File Structure

```
lib/
├── core/
│   ├── feature_name/
│   │   ├── feature_name.dart          # Main implementation
│   │   ├── feature_name_provider.dart  # State management
│   │   └── feature_name_state.dart    # State classes
├── features/
│   └── feature_name/
│       └── feature_name_screen.dart
└── shared/
    ├── widgets/
    └── theme/
```

### Widget Best Practices

```dart
// ✅ Good: Use const constructors
const MyWidget({super.key});

// ✅ Good: Extract small widgets
class ParentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Header(),
        Content(),
        Footer(),
      ],
    );
  }
}

// ❌ Bad: Inline everything
class ParentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text('Header'),
        ),
        // ... more inline widgets
      ],
    );
  }
}
```

## Testing

### Unit Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/my_test.dart
```

### Widget Tests

```dart
testWidgets('MyWidget displays text', (WidgetTester tester) async {
  await tester.pumpWidget(const MyWidget());
  expect(find.text('Hello'), findsOneWidget);
});
```

### Integration Tests

```bash
flutter test integration_test/
```

### Test Guidelines

- Test one thing per test
- Use descriptive test names
- Follow Arrange-Act-Assert pattern
- Mock external dependencies
- Aim for 80%+ code coverage on core features

## Documentation

### Code Documentation

```dart
/// Calculates the exponential backoff delay.
///
/// [attempt] is the current retry attempt number.
/// Returns a [Duration] between 1s and 60s.
Duration calculateBackoff(int attempt) {
  // ...
}
```

### README Updates

If your changes affect:
- Installation process → Update README.md
- Configuration → Update relevant docs
- New features → Add feature documentation
- Breaking changes → Document in CHANGELOG.md

## Questions?

- Open an issue for bugs or feature requests
- Join our [Discord community](https://discord.gg/hermesconsole)
- Check existing [discussions](https://github.com/hermes-console/hermes-console/discussions)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
