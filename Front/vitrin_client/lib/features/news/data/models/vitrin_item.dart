import '../../../../core/config/app_config.dart';

class VitrinItem {
  final int id;
  final String title;
  final String mainImg;
  final String createdAt;
  final bool isLocal;

  const VitrinItem({
    required this.id,
    required this.title,
    required this.mainImg,
    required this.createdAt,
    this.isLocal = false,
  });

  factory VitrinItem.fromJson(Map<String, dynamic> json, {bool isLocal = false}) {
    return VitrinItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? 'بدون عنوان',
      mainImg: AppConfig.resolveMediaUrl(json['main_img'] as String? ?? ''),
      createdAt: json['created_at'] as String? ?? '',
      isLocal: isLocal,
    );
  }
}
