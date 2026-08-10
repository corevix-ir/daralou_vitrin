import 'vitrin_item.dart';

class VitrinContentResponse {
  final List<VitrinItem> localContent;
  final List<VitrinItem> scrapContent;

  const VitrinContentResponse({
    required this.localContent,
    required this.scrapContent,
  });

  factory VitrinContentResponse.fromJson(Map<String, dynamic> json) {
    final localList = (json['local_content'] as List<dynamic>?)
            ?.map((e) => VitrinItem.fromJson(e as Map<String, dynamic>, isLocal: true))
            .toList() ??
        [];

    final scrapList = (json['scrap_content'] as List<dynamic>?)
            ?.map((e) => VitrinItem.fromJson(e as Map<String, dynamic>, isLocal: false))
            .toList() ??
        [];

    return VitrinContentResponse(
      localContent: localList,
      scrapContent: scrapList,
    );
  }

  List<VitrinItem> get combinedItems => [...localContent, ...scrapContent];
}
