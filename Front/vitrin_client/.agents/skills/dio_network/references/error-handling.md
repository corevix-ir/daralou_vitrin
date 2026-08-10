# Dio Error Handling & Network Exceptions Translation

## Overview
This document specifies how HTTP network failures, status codes, and timeouts are trapped, parsed, and translated into user-friendly Persian error messages dispatched via `GlobalSnackBar`.

---

## 1. Custom Domain Failures Hierarchy

```dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, [this.statusCode]);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('ارتباط با سرور برقرار نشد. لطفاً شبکه را بررسی کنید.');
}

class AuthFailure extends Failure {
  const AuthFailure() : super('احراز هویت معتبر نیست. لطفاً مجدداً وارد شوید.');
}
```

---

## 2. Dio Error Interceptor Implementation

```dart
import 'package:dio/dio.dart';
import '../../utils/global_keys.dart';
import '../../../shared/widgets/global_snackbar.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final String translatedMessage = _translateDioError(err);
    
    // Automatically trigger visual feedback on screen
    GlobalSnackBar.showError(translatedMessage);

    super.onError(err, handler);
  }

  String _translateDioError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'مهلت زمانی ارتباط با سرور به پایان رسید.';
      case DioExceptionType.connectionError:
        return 'شبکه در دسترس نیست. دستگاه در حالت آفلاین کار می‌کند.';
      case DioExceptionType.badResponse:
        final code = err.response?.statusCode;
        if (code == 401) return 'دسترسی غیرمجاز. نشست منقضی شده است.';
        if (code == 403) return 'شما مجوز دسترسی به این بخش را ندارید.';
        if (code == 404) return 'اطلاعات مورد نظر در سرور یافت نشد.';
        if (code != null && code >= 500) return 'خطای داخلی سرور ($code).';
        return 'پاسخ نامعتبر از سرور ($code).';
      default:
        return 'خطای غیرمنتظره رخ داده است.';
    }
  }
}
```
