# Asynchronous Programming & Real-time Tickers in Dart

## Overview
Kiosk applications rely heavily on non-blocking asynchronous operations and real-time updates for clock displays, live stock feeds (TSE FAMELI), commodity prices (LME Copper), and carousel auto-advancements.

---

## 1. Stream-Based Real-time Ticker Pattern

Use periodic `Stream` definitions with structured error handling for continuous ticker updates:

```dart
import 'dart:async';

class TickerStreamController {
  final StreamController<double> _copperPriceController = 
      StreamController<double>.broadcast();
  Timer? _pollingTimer;

  Stream<double> get copperPriceStream => _copperPriceController.stream;

  void startPolling({required Future<double> Function() fetchPrice}) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      try {
        final price = await fetchPrice();
        if (!_copperPriceController.isClosed) {
          _copperPriceController.add(price);
        }
      } catch (e) {
        if (!_copperPriceController.isClosed) {
          _copperPriceController.addError(e);
        }
      }
    });
  }

  void dispose() {
    _pollingTimer?.cancel();
    _copperPriceController.close();
  }
}
```

---

## 2. Heavy JSON Parsing in Isolates

To avoid drop frames (jank) during kiosk rendering, use `compute` or `Isolate.run` when parsing large JSON payloads:

```dart
import 'dart:convert';
import 'package:flutter/foundation.dart';

Future<List<Map<String, dynamic>>> parseLargeJsonPayload(String jsonString) async {
  return compute(_decodeAndProcessJson, jsonString);
}

List<Map<String, dynamic>> _decodeAndProcessJson(String jsonString) {
  final List<dynamic> decoded = jsonDecode(jsonString);
  return decoded.cast<Map<String, dynamic>>();
}
```

---

## 3. Debouncing & Throttling User Touches

Prevent multiple rapid taps on kiosk CTA buttons (e.g. `ثبت درخواست` or Pulse Survey face feedback buttons):

```dart
import 'dart:async';
import 'package:flutter/material.dart';

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
```
