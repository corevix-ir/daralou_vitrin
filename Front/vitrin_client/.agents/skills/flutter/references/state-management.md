# State Management Architecture for Kiosk Real-Time Tickers

## Overview
Kiosk state management requires low-overhead, memory-safe reactive updates for live clocks, continuous LME copper price ticks, and interactive survey touches.

---

## 1. Lightweight `ValueNotifier` Pattern for Module Tickers

For simple real-time updates (e.g. Copper price or TSE Stock), use lightweight `ValueNotifier` controllers to isolate re-renders to small widget subtrees.

```dart
import 'package:flutter/material.dart';
import '../../ticker/data/models/copper_price_model.dart';
import '../../ticker/data/services/ticker_service.dart';

class CopperPriceNotifier extends ValueNotifier<AsyncValue<CopperPriceModel>> {
  final TickerService _tickerService;

  CopperPriceNotifier(this._tickerService)
      : super(const AsyncValue.loading()) {
    fetchLatestPrice();
  }

  Future<void> fetchLatestPrice() async {
    try {
      value = const AsyncValue.loading();
      final price = await _tickerService.getCopperPrice();
      value = AsyncValue.data(price);
    } catch (e) {
      value = AsyncValue.error(e.toString());
    }
  }
}

class AsyncValue<T> {
  final T? data;
  final String? error;
  final bool isLoading;

  const AsyncValue.data(this.data) : error = null, isLoading = false;
  const AsyncValue.loading() : data = null, error = null, isLoading = true;
  const AsyncValue.error(this.error) : data = null, isLoading = false;
}
```

---

## 2. Consuming State with `ValueListenableBuilder`

```dart
import 'package:flutter/material.dart';
import 'copper_price_notifier.dart';

class LmeCopperPriceWidget extends StatelessWidget {
  final CopperPriceNotifier notifier;

  const LmeCopperPriceWidget({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AsyncValue<CopperPriceModel>>(
      valueListenable: notifier,
      builder: (context, state, child) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null) {
          return Text('Error: ${state.error}');
        }
        final copper = state.data!;
        return Text(
          '\$${copper.priceUsd.toStringAsFixed(0)} / ${copper.unit}',
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}
```
