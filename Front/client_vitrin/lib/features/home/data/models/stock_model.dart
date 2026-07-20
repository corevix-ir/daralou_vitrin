class StockModel {
  final String symbol;
  final String changePercent;
  final bool isPositive;
  final String lastUpdatedTime;

  StockModel({
    required this.symbol,
    required this.changePercent,
    required this.isPositive,
    required this.lastUpdatedTime,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      symbol: json['symbol'] as String? ?? 'TSE: FAMELI',
      changePercent: json['changePercent'] as String,
      isPositive: json['isPositive'] as bool? ?? true,
      lastUpdatedTime: json['lastUpdatedTime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'changePercent': changePercent,
      'isPositive': isPositive,
      'lastUpdatedTime': lastUpdatedTime,
    };
  }
}
