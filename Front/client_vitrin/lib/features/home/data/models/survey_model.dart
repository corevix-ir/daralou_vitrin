class SurveyModel {
  final String title;
  final String subtitle;

  SurveyModel({
    required this.title,
    required this.subtitle,
  });

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    return SurveyModel(
      title: json['title'] as String? ?? 'امروز از خدمات ما راضی بودید؟',
      subtitle: json['subtitle'] as String? ??
          'نظرات شما به ما در بهبود خدمات مجموعه کمک می‌کند.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
    };
  }
}
