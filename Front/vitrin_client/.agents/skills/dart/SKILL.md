# Skill: Modern Dart Standards & Architecture

## Overview
This skill defines coding standards, language features, and architectural best practices for writing high-performance, maintainable Dart code in the **Daralou Copper Kiosk** project.

## Core Language Rules

1. **Sound Null Safety:** Always mark fields explicitly as non-nullable unless `null` represents a valid domain state.
2. **Immutability First:** Use `const` constructors for all widgets and objects where possible. Prefer `final` for class fields.
3. **Explicit Typing:** Avoid using `dynamic` or implicit `var` when the type is not self-evident. Explicitly type function parameters and return values.
4. **Pattern Matching & Records (Dart 3+):** Leverage records for returning multiple values from internal utilities and sealed classes for exhaustive state modeling.

---

## Code Example: Sealed Class State Architecture

```dart
import 'package:flutter/foundation.dart';

@immutable
sealed class KioskState<T> {
  const KioskState();
}

class KioskStateInitial<T> extends KioskState<T> {
  const KioskStateInitial();
}

class KioskStateLoading<T> extends KioskState<T> {
  const KioskStateLoading();
}

class KioskStateSuccess<T> extends KioskState<T> {
  final T data;
  const KioskStateSuccess(this.data);
}

class KioskStateFailure<T> extends KioskState<T> {
  final String errorMessage;
  final Exception? exception;
  const KioskStateFailure(this.errorMessage, [this.exception]);
}
```

---

## Detailed References
- [Async Programming & Streams](references/async-programming.md)
- [Clean Code Guidelines](references/clean-code.md)
- [Data Models & Serialization](references/models-serialization.md)
