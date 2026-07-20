class LmeModel {
  final String title;
  final String priceFormatted;
  final String unit;
  final String trendPercent;
  final bool isPositiveTrend;
  final String timeFrame;

  LmeModel({
    required this.title,
    required this.priceFormatted,
    required this.unit,
    required this.trendPercent,
    required this.isPositiveTrend,
    required this.timeFrame,
  });

  factory LmeModel.fromJson(Map<String, dynamic> json) {
    return LmeModel(
      title: json['title'] as String? ?? 'قیمت مس LME',
      priceFormatted: json['priceFormatted'] as String,
      unit: json['unit'] as String? ?? 'تن',
      trendPercent: json['trendPercent'] as String,
      isPositiveTrend: json['isPositiveTrend'] as bool? ?? true,
      timeFrame: json['timeFrame'] as String? ?? '24h',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'priceFormatted': priceFormatted,
      'unit': unit,
      'trendPercent': trendPercent,
      'isPositiveTrend': isPositiveTrend,
      'timeFrame': timeFrame,
    };
  }
}
