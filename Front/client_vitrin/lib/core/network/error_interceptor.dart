import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/global_keys.dart';

/// Centralized error handler interceptor that catches any network error (4xx, 5xx, timeout)
/// and displays a global floating SnackBar via [rootScaffoldMessengerKey] without BuildContext.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final String errorMessage = _extractErrorMessage(err);

    _showGlobalErrorSnackBar(errorMessage);

    super.onError(err, handler);
  }

  String _extractErrorMessage(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'خطا در برقراری ارتباط با سرور (پایان مهلت زمان)';

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final data = err.response?.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'].toString();
        }
        if (statusCode != null) {
          if (statusCode >= 500) {
            return 'خطای سرور داخلی (کد $statusCode). لطفا بعداً تلاش کنید.';
          } else if (statusCode == 404) {
            return 'اطلاعات مورد نظر یافت نشد (کد ۴۰۴)';
          } else if (statusCode == 403) {
            return 'سطح دسترسی غیرمجاز می‌باشد (کد ۴۰۳)';
          }
        }
        return 'خطای ارتباط با سرور (کد $statusCode)';

      case DioExceptionType.cancel:
        return 'درخواست توسط سیستم لغو شد';

      case DioExceptionType.connectionError:
        return 'ارتباط با شبکه برقرار نشد. لطفا اتصال شبکه را بررسی کنید.';

      default:
        return err.message ?? 'خطای غیرمنتظره‌ای رخ داده است';
    }
  }

  void _showGlobalErrorSnackBar(String message) {
    final messengerState = rootScaffoldMessengerKey.currentState;
    if (messengerState == null) return;

    messengerState.hideCurrentSnackBar();
    messengerState.showSnackBar(
      SnackBar(
        elevation: 8,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: AppColors.crimsonRed,
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
