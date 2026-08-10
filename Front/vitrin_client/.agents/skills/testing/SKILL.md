# Skill: Kiosk Testing Strategy & Test Automation

## Overview
This skill outlines unit testing for data models/services, widget testing for Bento Grid components, and integration testing for 24/7 Kiosk uptime stability.

---

## 1. Unit Testing Models & Services

Use `flutter_test` to verify JSON serialization, fallback defaults, and error handlers:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:vitrin_client/features/ticker/data/models/copper_price_model.dart';

void main() {
  group('CopperPriceModel Unit Tests', () {
    test('should correctly parse valid JSON payload', () {
      final json = {
        'price_usd': 9450.0,
        'unit': 'تن',
        'change_24h': 2.1,
        'last_updated': '2026-08-08T10:24:00Z',
      };

      final model = CopperPriceModel.fromJson(json);

      expect(model.priceUsd, 9450.0);
      expect(model.unit, 'تن');
      expect(model.changePercentage24h, 2.1);
    });

    test('should provide defensive default values on missing JSON fields', () {
      final json = <String, dynamic>{};

      final model = CopperPriceModel.fromJson(json);

      expect(model.priceUsd, 0.0);
      expect(model.unit, 'تن');
      expect(model.changePercentage24h, 0.0);
    });
  });
}
```

---

## 2. Widget Testing Bento Grid Components

Verify RTL text rendering and CTA touch triggers:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitrin_client/shared/widgets/bento_card.dart';

void main() {
  testWidgets('BentoCard renders child and responds to tap gesture', (tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BentoCard(
            onTap: () => tapped = true,
            child: const Text('ثبت درخواست'),
          ),
        ),
      ),
    );

    expect(find.text('ثبت درخواست'), findsOneWidget);

    await tester.tap(find.text('ثبت درخواست'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
```
