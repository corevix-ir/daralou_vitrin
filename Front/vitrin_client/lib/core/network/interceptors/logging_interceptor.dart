import 'package:dio/dio.dart';
import '../../config/app_config.dart';

/// Prints every request/response (method, URL, body, status, and where the
/// response came from) to the terminal - only while [AppConfig.isDebug] is
/// on, so none of this ships to a production console.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (AppConfig.current.isDebug) {
      final buffer = StringBuffer()
        ..writeln('┌── درخواست ─────────────────────────────')
        ..writeln('│ ${options.method} ${options.uri}')
        ..writeln('│ Headers: ${options.headers}');
      if (options.queryParameters.isNotEmpty) {
        buffer.writeln('│ Query: ${options.queryParameters}');
      }
      if (options.data != null) {
        buffer.writeln('│ Body: ${options.data}');
      }
      buffer.write('└────────────────────────────────────────');
      // ignore: avoid_print
      print(buffer.toString());
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (AppConfig.current.isDebug) {
      final buffer = StringBuffer()
        ..writeln('┌── پاسخ ────────────────────────────────')
        ..writeln('│ از: ${response.requestOptions.method} ${response.requestOptions.uri}')
        ..writeln('│ Status: ${response.statusCode}')
        ..writeln('│ Data: ${response.data}')
        ..write('└────────────────────────────────────────');
      // ignore: avoid_print
      print(buffer.toString());
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (AppConfig.current.isDebug) {
      final buffer = StringBuffer()
        ..writeln('┌── خطا ─────────────────────────────────')
        ..writeln('│ از: ${err.requestOptions.method} ${err.requestOptions.uri}')
        ..writeln('│ Status: ${err.response?.statusCode}')
        ..writeln('│ Data: ${err.response?.data}')
        ..write('└────────────────────────────────────────');
      // ignore: avoid_print
      print(buffer.toString());
    }
    handler.next(err);
  }
}
