# Feature-First Organization Pattern in Flutter

## Overview
This document specifies the exact internal anatomy of feature folders in `vitrin_client`.

---

## 1. Internal Feature Module Hierarchy

Every sub-feature in `lib/features/<feature_name>/` follows this exact standard:

```
lib/features/ticker/
├── data/
│   ├── models/
│   │   ├── copper_price_model.dart
│   │   └── tse_stock_model.dart
│   └── services/
│       ├── ticker_service.dart
│       └── remote_ticker_service.dart
├── mock/
│   ├── mock_ticker_data.dart
│   └── mock_ticker_service.dart
├── presentation/
│   ├── controllers/
│   │   └── ticker_notifier.dart
│   └── widgets/
│       ├── lme_copper_ticker_card.dart
│       ├── tse_stock_card.dart
│       └── components/
│           └── percentage_badge.dart
└── ticker_exports.dart               # Barrel file for public exports
```

---

## 2. Barrel File Export Rule (`ticker_exports.dart`)

To prevent messy cross-file imports, each feature exposes only public components via a single barrel file:

```dart
// lib/features/ticker/ticker_exports.dart
export 'data/models/copper_price_model.dart';
export 'data/models/tse_stock_model.dart';
export 'presentation/widgets/lme_copper_ticker_card.dart';
export 'presentation/widgets/tse_stock_card.dart';
```

Other features import only `package:vitrin_client/features/ticker/ticker_exports.dart`.
