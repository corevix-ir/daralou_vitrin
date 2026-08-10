# Data Models & Serialization Standards in Dart

## Overview
Data models in **vitrin_client** must be immutable, crash-resilient, and feature robust JSON parsing and fallback mechanisms.

---

## 1. Standard Immutable Data Model Pattern

Below is the standard data model blueprint for domain objects (e.g., LME Copper Ticker data):

```dart
import 'package:flutter/foundation.dart';

@immutable
class CopperPriceModel {
  final double priceUsd;
  final String unit;
  final double changePercentage24h;
  final DateTime lastUpdated;

  const CopperPriceModel({
    required this.priceUsd,
    required this.unit,
    required this.changePercentage24h,
    required this.lastUpdated,
  });

  factory CopperPriceModel.fromJson(Map<String, dynamic> json) {
    return CopperPriceModel(
      priceUsd: (json['price_usd'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'تن',
      changePercentage24h: (json['change_24h'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: json['last_updated'] != null
          ? DateTime.tryParse(json['last_updated'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price_usd': priceUsd,
      'unit': unit,
      'change_24h': changePercentage24h,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  CopperPriceModel copyWith({
    double? priceUsd,
    String? unit,
    double? changePercentage24h,
    DateTime? lastUpdated,
  }) {
    return CopperPriceModel(
      priceUsd: priceUsd ?? this.priceUsd,
      unit: unit ?? this.unit,
      changePercentage24h: changePercentage24h ?? this.changePercentage24h,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CopperPriceModel &&
          runtimeType == other.runtimeType &&
          priceUsd == other.priceUsd &&
          unit == other.unit &&
          changePercentage24h == other.changePercentage24h &&
          lastUpdated == other.lastUpdated;

  @override
  int get hashCode =>
      priceUsd.hashCode ^
      unit.hashCode ^
      changePercentage24h.hashCode ^
      lastUpdated.hashCode;
}
```

---

## 2. Dynamic Field Defensive Parsing

Always handle potential null or mismatched backend types (e.g. integer returned instead of double or string returned instead of int):

```dart
double safeParseDouble(dynamic value, [double defaultValue = 0.0]) {
  if (value == null) return defaultValue;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}
```
