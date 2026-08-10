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
        if (parsed.combinedItems.isNotEmpty) {
          return parsed.combinedItems;
        }
      }
    } on DioException catch (_) {
      // Endpoint error trapped by interceptor
    } catch (_) {}

    return _getFallbackItems();
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

    // Fallback if backend API is not yet reachable
    final fallbackList = _getFallbackScrapItems();
    return ScrapNewsResponse(
      items: fallbackList.take(size).toList(),
      total: fallbackList.length,
      page: page,
      size: size,
    );
  }

  List<VitrinItem> _getFallbackItems() {
    return const [
      VitrinItem(
        id: 101,
        title: 'بازدید هیئت مدیره از زیرساخت‌های جدید لابی و مرکز خدمات پرسنلی',
        mainImg: 'https://picsum.photos/seed/daralou1/1200/600',
        createdAt: '2026-08-08',
        isLocal: true,
      ),
      VitrinItem(
        id: 102,
        title: 'افتتاح مجتمع ورزشی و رفاهی شرکت مس درآلو',
        mainImg: 'https://picsum.photos/seed/daralou2/1200/600',
        createdAt: '2026-08-07',
        isLocal: true,
      ),
      VitrinItem(
        id: 103,
        title: 'رکورد جدید تولید سالانه در مجتمع معدنی درآلو ثبت شد',
        mainImg: 'https://picsum.photos/seed/daralou3/1200/600',
        createdAt: '2026-08-06',
        isLocal: false,
      ),
    ];
  }

  List<VitrinItem> _getFallbackScrapItems() {
    return const [
      VitrinItem(
        id: 201,
        title: 'ارتقای سیستم‌های ایمنی و پایش هوشمند در فاز دو کارخانه کارخانجات مس',
        mainImg: 'https://picsum.photos/seed/scrap1/800/500',
        createdAt: '۱۸ مرداد ۱۴۰۵',
        isLocal: false,
      ),
      VitrinItem(
        id: 202,
        title: 'برگزاری کارگاه تخصصی مدیریت انرژی و بهینه‌سازی مصرف در صنایع معدنی',
        mainImg: 'https://picsum.photos/seed/scrap2/800/500',
        createdAt: '۱۷ مرداد ۱۴۰۵',
        isLocal: false,
      ),
      VitrinItem(
        id: 203,
        title: 'کسب رتبه برتر شرکت مس درآلو در حوزه مسئولیت‌های اجتماعی و محیط زیست',
        mainImg: 'https://picsum.photos/seed/scrap3/800/500',
        createdAt: '۱۶ مرداد ۱۴۰۵',
        isLocal: false,
      ),
      VitrinItem(
        id: 204,
        title: 'تکمیل ساخت و بهره‌برداری از نیروگاه خورشیدی اختصاصی درآلو',
        mainImg: 'https://picsum.photos/seed/scrap4/800/500',
        createdAt: '۱۵ مرداد ۱۴۰۵',
        isLocal: false,
      ),
      VitrinItem(
        id: 205,
        title: 'تقدیر از پرسنل نمونه و نخبگان مهندسی شرکت مس درآلو',
        mainImg: 'https://picsum.photos/seed/scrap5/800/500',
        createdAt: '۱۴ مرداد ۱۴۰۵',
        isLocal: false,
      ),
    ];
  }
}
