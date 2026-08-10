import 'vitrin_item.dart';

class ScrapNewsResponse {
  final List<VitrinItem> items;
  final int total;
  final int page;
  final int size;

  const ScrapNewsResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.size,
  });

  factory ScrapNewsResponse.fromJson(dynamic json, int page, int size) {
    if (json is List) {
      final list = json
          .map((e) => VitrinItem.fromJson(e as Map<String, dynamic>, isLocal: false))
          .toList();
      return ScrapNewsResponse(
        items: list,
        total: list.length,
        page: page,
        size: size,
      );
    } else if (json is Map<String, dynamic>) {
      final rawItems = json['items'] ?? json['results'] ?? json['data'];
      List<VitrinItem> list = [];
      if (rawItems is List) {
        list = rawItems
            .map((e) => VitrinItem.fromJson(e as Map<String, dynamic>, isLocal: false))
            .toList();
      }
      final totalCount = (json['total'] ?? json['count'] ?? list.length) as int;
      return ScrapNewsResponse(
        items: list,
        total: totalCount,
        page: (json['page'] as int?) ?? page,
        size: (json['size'] as int?) ?? size,
      );
    }
    return ScrapNewsResponse(items: [], total: 0, page: page, size: size);
  }
}
