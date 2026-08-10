import 'package:dio/dio.dart';
import '../../../shared/widgets/global_snackbar.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final String message = _translateError(err);
    GlobalSnackBar.showError(message);
    super.onError(err, handler);
  }

  String _translateError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'مهلت زمانی ارتباط با سرور به پایان رسید.';
      case DioExceptionType.connectionError:
        return 'شبکه در دسترس نیست. لطفا اتصال به اینترنت را بررسی کنید.';
      case DioExceptionType.badResponse:
        final code = err.response?.statusCode;
        if (code == 401) return 'دسترسی غیرمجاز. لطفا وارد حساب دستگاه شوید.';
        if (code == 403) return 'شما مجوز دسترسی به این بخش را ندارید.';
        if (code == 404) return 'اطلاعات درخواستی یافت نشد.';
        if (code != null && code >= 500) return 'خطای داخلی سرور ($code).';
        return 'خطای سرور ($code).';
      default:
        return 'خطایی در برقراری ارتباط رخ داد.';
    }
  }
}
