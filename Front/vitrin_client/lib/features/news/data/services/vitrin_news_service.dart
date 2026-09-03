import 'package:dio/dio.dart';
import '../../../../core/network/core_http_client.dart';
import '../models/scrap_news_response.dart';
import '../models/vitrin_content_response.dart';
import '../models/vitrin_item.dart';

class VitrinNewsService {
  final CoreHttpClient _client = CoreHttpClient.instance;

  Future<List<VitrinItem>> getVitrinContents() async {
    try {
      final response = await _client.dio.get('/contents/vitrin');

      if (response.statusCode == 200 && response.data != null) {
        final parsed = VitrinContentResponse.fromJson(response.data);
        return parsed.combinedItems;
      }
    } on DioException catch (_) {
      // Endpoint error trapped by interceptor
    } catch (_) {}

    return const [];
  }

  Future<ScrapNewsResponse> getScrapNews({int page = 1, int size = 20}) async {
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

    return ScrapNewsResponse(items: const [], total: 0, page: page, size: size);
  }
}
