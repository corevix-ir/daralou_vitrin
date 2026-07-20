class ServiceModel {
  final String id;
  final String sectionTitle;
  final String title;
  final String subtitle;
  final String buttonText;

  ServiceModel({
    required this.id,
    required this.sectionTitle,
    required this.title,
    required this.subtitle,
    required this.buttonText,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      sectionTitle: json['sectionTitle'] as String? ?? 'مرکز خدمات پرسنلی',
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      buttonText: json['buttonText'] as String? ?? 'شروع رزرو',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sectionTitle': sectionTitle,
      'title': title,
      'subtitle': subtitle,
      'buttonText': buttonText,
    };
  }
}
