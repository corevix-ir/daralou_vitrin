# Skill: Dio Networking & HTTP Service Architecture

## Overview
This skill documents network client configuration, interceptor chains, token refresh pipelines, and fault-tolerant error handling using `dio` for the **Daralou Copper Kiosk** project.

## Core Rules for Dio Networking

1. **Singleton Wrapper Instance:** Never instantiate raw `Dio()` directly inside UI widgets or repositories. Inject `CoreHttpClient`.
2. **Explicit Timeouts:** `connectTimeout` and `receiveTimeout` must be bounded (default 10 seconds) to prevent kiosk UI blocking.
3. **Structured Interceptor Pipeline:** All requests pass through Logging, Authentication, Header, and Error Translation interceptors.
4. **Token Refresh Synchronization:** Queued token refresh logic prevents concurrent request failures during JWT rotation.

---

## Code Example: Service Layer Integration

```dart
import 'package:dio/dio.dart';
import '../../core/network/core_http_client.dart';
import '../models/news_item.dart';

class NewsService {
  final CoreHttpClient _client;

  NewsService(this._client);

  Future<List<NewsItem>> getHeroNews() async {
    try {
      final response = await _client.dio.get('/news/hero');
      final List<dynamic> data = response.data['items'];
      return data.map((json) => NewsItem.fromJson(json)).toList();
    } on DioException catch (e) {
      throw FormatException('Failed to load hero news: ${e.message}');
    }
  }
}
```

---

## Detailed References
- [Error Handling & Mapping](references/error-handling.md)
- [Custom Interceptors](references/interceptors.md)
- [JWT Token Refresh Pipeline](references/token-refresh.md)
