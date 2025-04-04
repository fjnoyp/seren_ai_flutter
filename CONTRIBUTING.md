# Contributing to Seren AI

Thank you for your interest in contributing to Seren AI! This document outlines the process for contributing and development guidelines.

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio or VS Code with Flutter extensions
- Firebase CLI (for web deployment)
- Git

### Environment Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/fjnoyp/seren_ai_flutter.git
   cd seren_ai_flutter
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up pre-commit hooks:
   ```bash
   git config --local core.hooksPath .github/hooks
   ```

## Development Workflow

### Branch Naming

- Feature branches: `feature/descriptive-name`
- Bug fixes: `fix/issue-description`
- Refactoring: `refactor/component-name`

### Commit Guidelines

We follow conventional commits:
- `feat:` for new features
- `fix:` for bug fixes
- `refactor:` for code changes that neither fix bugs nor add features
- `docs:` for documentation changes
- `test:` for adding or modifying tests

### Pull Request Process

1. Create a branch from `main`
2. Make your changes
3. Test thoroughly
4. Create a pull request with a clear description
5. Address any feedback from code review

## Web Deployment

For Firebase web deployment:
```bash
firebase login 
firebase experiments:enable webframeworks 
firebase init hosting 
firebase deploy
```

## Architecture Guidelines

### State Management

We use Riverpod for state management. Please follow these guidelines:

1. **Listen vs Watch in Riverpod**
   - `listen` does not rebuild the provider, it just calls the callback when the data changes
   - `watch` rebuilds the provider and all its dependents

2. **Avoiding State Modification Issues**
   - ⚠️ **WARNING:** Never use `ref.watch()` to access a provider when you intend to modify its state. Always use `ref.read()` instead.

```dart
// WRONG - Can cause dependency cycles and errors:
ref.watch(someProvider.notifier).state = newValue;

// CORRECT - Use read when you're modifying state:
ref.read(someProvider.notifier).state = newValue;
```

### DateTime Handling

For all DateTime calculations USE UTC - for any display use `toLocal()`:

```dart
// Storing or calculating with dates
final utcDateTime = DateTime.now().toUtc();

// Displaying dates to users
final localDisplayTime = utcDateTime.toLocal();
```

Postgres stores all datetimes in UTC, so any datetime received must be converted to the local timezone before displaying.

## Project Resources

- **Miro Board** (User Flow Diagrams): [View Board](https://miro.com/app/board/uXjVKCs7dtw=/)
- **Figma Design** (UI Screens): [View Design](https://www.figma.com/design/WD79K7Z9YAXc8SwoTU5r0n/Figma-basics?node-id=1669-162202&t=VU4uBrXEwiZMR5nD-0)
- **AI Flow Documentation**: [View Doc](https://docs.google.com/document/d/1MAOogPCurlaLiia1DLNlKJt969z6Xy0RG4gjaaeKM1g/)


# Setup 


We have a pre-commit hook, you must configure to run using this onetime setup:

```bash
git config --local core.hooksPath .github/hooks
```
