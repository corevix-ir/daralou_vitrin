import '../../../../core/config/app_config.dart';

/// Full detail payload for `GET /contents/{content_id}`. Kept separate from
/// [VitrinItem] (the lightweight card model used by list/carousel views)
/// since the detail endpoint returns a materially different shape - full
/// scraped `body` HTML, image gallery, external source link, etc.
class ContentDetail {
  final int id;
  final String contentType;
  final String title;
  final String summary;
  final String bodyHtml;
  final String mainImgUrl;
  final List<String> extraImgList;
  final String externalUrl;
  final String source;
  final int priority;
  final bool isPublished;
  final String createdAt;
  final String updatedAt;
  final String startDate;
  final String endDate;

  const ContentDetail({
    required this.id,
    required this.contentType,
    required this.title,
    required this.summary,
    required this.bodyHtml,
    required this.mainImgUrl,
    required this.extraImgList,
    required this.externalUrl,
    required this.source,
    required this.priority,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
    required this.startDate,
    required this.endDate,
  });

  bool get hasExternalUrl => externalUrl.trim().isNotEmpty;

  factory ContentDetail.fromJson(Map<String, dynamic> json) {
    String str(dynamic value) => value?.toString() ?? '';

    return ContentDetail(
      id: (json['id'] as num?)?.toInt() ?? 0,
      contentType: str(json['content_type']),
      title: str(json['title']).isEmpty ? 'بدون عنوان' : str(json['title']),
      summary: str(json['summary']),
      bodyHtml: str(json['body']),
      mainImgUrl: AppConfig.resolveMediaUrl(str(json['main_img_url'])),
      extraImgList: ((json['extra_img_list'] as List<dynamic>?) ?? const [])
          .map((e) => AppConfig.resolveMediaUrl(e.toString()))
          .where((e) => e.isNotEmpty)
          .toList(),
      externalUrl: str(json['external_url']),
      source: str(json['source']),
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      isPublished: json['is_published'] as bool? ?? true,
      // The backend has been observed to send these under both camelCase
      // and Pascal-cased keys depending on the route - accept either.
      createdAt: str(json['createdAt'] ?? json['CreatedAt'] ?? json['created_at']),
      updatedAt: str(json['updatedAt'] ?? json['UpdatedAt'] ?? json['updated_at']),
      startDate: str(json['start_date']),
      endDate: str(json['end_date']),
    );
  }
}
