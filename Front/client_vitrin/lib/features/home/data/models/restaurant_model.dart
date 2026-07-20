class RestaurantModel {
  final String title;
  final String subtitle;

  RestaurantModel({
    required this.title,
    required this.subtitle,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      title: json['title'] as String? ?? 'منوی رستوران',
      subtitle: json['subtitle'] as String? ?? 'مشاهده غذاهای امروز',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
    };
  }
}
