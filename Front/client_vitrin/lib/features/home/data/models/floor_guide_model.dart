class FloorGuideModel {
  final String title;
  final String description;

  FloorGuideModel({
    required this.title,
    required this.description,
  });

  factory FloorGuideModel.fromJson(Map<String, dynamic> json) {
    return FloorGuideModel(
      title: json['title'] as String? ?? 'راهنمای طبقات و دایرکتوری',
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }
}
