# Clean Code Standards for Dart & Kiosk Development

## Overview
This document outlines strict clean code practices for the **vitrin_client** application.

---

## 1. Single Responsibility Principle (SRP)
Each class or file must serve exactly one operational role.

- **Bad:** A widget that handles Dio HTTP calls, parses JSON, computes calculations, and renders UI.
- **Good:** Split into `CopperPriceModel`, `CopperPriceService`, `CopperPriceNotifier`, and `LmeCopperTickerCard`.

---

## 2. Explicit Extension Methods for Domain Conversions

Use Dart extension methods to keep widget files clean of formatting logic:

```dart
import 'package:intl/intl.dart';

extension CurrencyFormatting on double {
  String toUsdFormat() {
    final formatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(this);
  }

  String toPercentageFormat() {
    final prefix = this >= 0 ? '+' : '';
    return '$prefix${toStringAsFixed(1)}%';
  }
}
```

---

## 3. Avoid Hardcoded String Literals

Keep UI strings organized. In Persian kiosk UI, use structured constant classes or localization extensions:

```dart
abstract class PersianStrings {
  static const String appTitle = 'شرکت مس درآلو';
  static const String lobbyLocation = 'ساختمان مرکزی | لابی';
  static const String leaveRegistration = 'ثبت مرخصی و ماموریت';
  static const String lmeCopperPriceHeader = 'قیمت مس LME';
  static const String floorDirectoryHeader = 'راهنمای طبقات و دایرکتوری';
  static const String surveyQuestion = 'امروز از خدمات ما راضی بودید؟';
  static const String emergencyFooterText = 
      'وضعیت سیستم: فعال | پروتکل اضطراری فعال: با امنیت سایت داخلی ۹۱۱ تماس بگیرید';
}
```
