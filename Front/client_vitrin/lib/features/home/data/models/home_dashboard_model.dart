import 'news_model.dart';
import 'service_model.dart';
import 'lme_model.dart';
import 'stock_model.dart';
import 'floor_guide_model.dart';
import 'restaurant_model.dart';
import 'transit_model.dart';
import 'survey_model.dart';

class HomeDashboardModel {
  final String locationTag;
  final String temperature;
  final String time;
  final NewsModel news;
  final ServiceModel service;
  final LmeModel lme;
  final StockModel stock;
  final FloorGuideModel floorGuide;
  final RestaurantModel restaurant;
  final TransitModel transit;
  final SurveyModel survey;
  final String emergencyMarqueeText;

  HomeDashboardModel({
    required this.locationTag,
    required this.temperature,
    required this.time,
    required this.news,
    required this.service,
    required this.lme,
    required this.stock,
    required this.floorGuide,
    required this.restaurant,
    required this.transit,
    required this.survey,
    required this.emergencyMarqueeText,
  });

  factory HomeDashboardModel.fromJson(Map<String, dynamic> json) {
    return HomeDashboardModel(
      locationTag: json['locationTag'] as String? ?? 'ساختمان مرکزی | لابی',
      temperature: json['temperature'] as String? ?? '28°C',
      time: json['time'] as String? ?? '10:24',
      news: NewsModel.fromJson(json['news'] as Map<String, dynamic>),
      service: ServiceModel.fromJson(json['service'] as Map<String, dynamic>),
      lme: LmeModel.fromJson(json['lme'] as Map<String, dynamic>),
      stock: StockModel.fromJson(json['stock'] as Map<String, dynamic>),
      floorGuide: FloorGuideModel.fromJson(json['floorGuide'] as Map<String, dynamic>),
      restaurant: RestaurantModel.fromJson(json['restaurant'] as Map<String, dynamic>),
      transit: TransitModel.fromJson(json['transit'] as Map<String, dynamic>),
      survey: SurveyModel.fromJson(json['survey'] as Map<String, dynamic>),
      emergencyMarqueeText: json['emergencyMarqueeText'] as String? ??
          'وضعیت سیستم: فعال | پروتکل اضطراری فعال: با امنیت سایت داخلی ۹۱۱ تماس بگیرید',
    );
  }
}
