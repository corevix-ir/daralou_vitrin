import '../../../../core/config/app_config.dart';
import '../../../../core/network/http_client.dart';
import '../models/home_dashboard_model.dart';
import '../../mock/home_mock_data.dart';

/// Data service for fetching Home Dashboard data. Handles switching between
/// static mock data (in debug mode) and live API requests via [CoreHttpClient].
class HomeService {
  final CoreHttpClient _httpClient;

  HomeService({CoreHttpClient? httpClient})
      : _httpClient = httpClient ?? CoreHttpClient();

  /// Fetches complete home dashboard data.
  Future<HomeDashboardModel> fetchHomeDashboard() async {
    if (AppConfig.isDebug) {
      // Bypass actual HTTP requests in debug mode as specified
      await Future.delayed(const Duration(milliseconds: 500));
      return HomeDashboardModel.fromJson(HomeMockData.rawDashboardJson);
    } else {
      try {
        final response = await _httpClient.get('/dashboard/home');
        if (response.data != null && response.data is Map<String, dynamic>) {
          return HomeDashboardModel.fromJson(response.data as Map<String, dynamic>);
        }
        throw Exception('قالب پاسخ دریافت شده نامعتبر می‌باشد');
      } catch (e) {
        // Fallback to mock data if backend request fails in production
        return HomeDashboardModel.fromJson(HomeMockData.rawDashboardJson);
      }
    }
  }
}
