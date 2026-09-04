import 'package:dio/dio.dart';
import '../../../../core/network/core_http_client.dart';
import '../models/content_detail.dart';
import '../models/scrap_news_response.dart';
import '../models/vitrin_content_response.dart';
import '../models/vitrin_item.dart';

class VitrinNewsService {
  final CoreHttpClient _client = CoreHttpClient.instance;

  /// Returns `null` on a failed request (network error, non-200, bad body) -
  /// distinct from a successful response that just happens to have zero
  /// items - so callers can tell "genuinely empty" apart from "couldn't
  /// reach the server" and choose to keep showing stale-but-valid content
  /// instead of wiping it on a transient failure.
  Future<List<VitrinItem>?> getVitrinContents() async {
    try {
      final response = await _client.dio.get('/contents/vitrin');

      if (response.statusCode == 200 && response.data != null) {
        final parsed = VitrinContentResponse.fromJson(response.data);
        return parsed.combinedItems;
      }
    } on DioException catch (_) {
      // Endpoint error trapped by interceptor
    } catch (_) {}

    return null;
  }

  /// Returns `null` on a failed request, for the same reason as
  /// [getVitrinContents].
  Future<ScrapNewsResponse?> getScrapNews({int page = 1, int size = 20}) async {
    try {
      final response = await _client.dio.get(
        '/contents/scrap',
        queryParameters: {'page': page, 'size': size},
      );

      if (response.statusCode == 200 && response.data != null) {
        return ScrapNewsResponse.fromJson(response.data, page, size);
      }
    } on DioException catch (_) {
      // Endpoint error trapped by interceptor
    } catch (_) {}

    return null;
  }

  /// Returns `null` on a failed request, for the same reason as
  /// [getVitrinContents].
  Future<ContentDetail?> getContentDetail(int contentId) async {
    try {
      final response = await _client.dio.get('/contents/$contentId');

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return ContentDetail.fromJson(response.data as Map<String, dynamic>);
      }
    } on DioException catch (_) {
      // Endpoint error trapped by interceptor
    } catch (_) {}

    return null;
  }
}
